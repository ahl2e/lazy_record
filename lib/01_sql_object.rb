require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
      LIMIT
        0
      SQL
      @columns = cols.first.map!{|el| el.to_sym}
  end

  def self.finalize!

    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end

      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
  end


  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.underscore.downcase.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      SQL
    )
    self.parse_all(results)

  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    object = DBConnection.execute(<<-SQL, id)
      SELECT #{table_name}.*
      FROM #{self.table_name}
      WHERE id = ?
      SQL

      self.parse_all(object).first

  end

  def initialize(params = {})
    params.each do |attribute,value|
      attribute = attribute.to_sym
      if self.class.columns.include?(attribute)
        self.send("#{attribute}=", value)
      else
      raise "unknown attribute '#{attribute}'"
    end
  end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    cols = self.class.columns.drop(1)
    col_names = cols.map{|col| col.to_s}.join(", ")
    question_marks = (["?"]* cols.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    change = self.class.columns.map{|col| "#{col} = ?"}.join(",")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{change}
      WHERE
        #{self.class.table_name}.id = ?
      SQL
  end

  def save
    if id
      update
    else
      insert
    end
  end
end
