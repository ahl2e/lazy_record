# lazy_record

Lazy Record is lightweight Object Relational Mapping software inspired by Rails' Active Record

* Metaprogramming allows users to easily create connections between data tables.
* Complicted SQL queries are automated for the user

## Demo

### Databases

#### Cats
|id|ownerId|name|color|gender|
|--|--------|----|-----|------|
|1|1|Oscar|black|male|
|2|1|Misty|white|female|
|3|3|Sparkles|orange|male|
|4|2|Patches|brown|female|
|5|4|Tigger|orange|male|

#### People
|id|name|gender|
|--|----|------|
|1|Tim|male|
|2|Mary|female|
|3|Molly|female|
|4|John|male|

### SQLObject

```ruby
class Cat < SQLObject
end 

class Person < SQLObject
end
```

### ::all

`::all` allows you to find all SQLObjects from a table in the database.

```ruby
people = Person.all
```

Result

```ruby
{
  id: 1,
  name: 'Tim',
  gender: 'female'
},
{
  id: 2,
  name: 'Mary',
  gender: 'female'
},
{
  id: 3,
  name: 'Molly',
  gender: 'female'
},
{
  id: 4,
  name: 'John',
  gender: 'male'
}
```

### ::find

`::find` allows you to find a single SQLObject from the database by its id.

```ruby
tim = Person.find(1)
```

Result

```ruby
{
  id: 1,
  name: 'Tim',
  gender: 'male'
}
```

### ::find_by

`::find_by` allows you to find a single SQLObject from the database by any attribute and value passed in as a key-value pair.

```ruby
time = Person.find_by(id: 1)
```

Result

```ruby
{
  id: 1,
  name: 'Tim',
  gender: 'male'
}
```

### #insert

`#insert` allows you to insert a newly created SQLObject into the database, and automatically assigns it a valid id.

```ruby
mike = Person.new(name: 'Mike', gender: 'male')
mike.insert
```
New Database

|id|name|gender|
|--|----|------|
|1|Tim|male|
|2|Mary|female|
|3|Molly|female|
|4|John|male|
|5|Mike|male|

### #update

`#update` allows you to update an existing SQLObject to the database.

```ruby
tim = Person.find(1)
tim.name = 'Bob'
tim.update
```

New Database

|id|name|gender|
|--|----|------|
|1|Bob|male|
|2|Mary|female|
|3|Molly|female|
|4|John|male|
|5|Mike|male|

### #save

`#save` allows you to insert a new SQLObject or update an existing SQLObject if it already exists.

```ruby
bob = Person.find(1)
bob.name = 'Tim'
jenn = Person.new(name: 'Jenn', gender: 'female')

bob.save
jenn.save
```

New Database

|id|name|gender|
|--|----|------|
|1|Tim|male|
|2|Mary|female|
|3|Molly|female|
|4|John|male|
|5|Mike|male|
|6|Jenn|female|

### ::where

`::where` allows you to find all SQLObjects from the database by any attribute and value passed in as a key-value pair.

```ruby
people = Person.where(gender: male)
```

Result

```ruby
{
  id: 1,
  name: 'Tim',
  gender: 'male'
},
{
  id: 4,
  name: 'John',
  gender: 'male'
},
{
  id: 5,
  name: 'Mike',
  gender: 'male'
}
```

### ::has_many

`::has_many` allows you to define a 'has-many' relationship between 2 SQLObjects. 

```ruby
class Person < SQLObject
  has_many :cats,
    foreign_key: :ownerId,
    primary_key: :id,
    class_name: "Cat"
end 

tim = Person.find(1)
tim.cats
```

Result

```ruby
{
  id: 1,
  ownerId: 1,
  name: "Oscar",
  color: "black",
  gender: "male"
},
{
  id: 2,
  ownderId: 1,
  name: "Misty",
  color: "white",
  gender: "female"
}
```

### ::belongs_to

`::belongs_to` allows you to define a 'has-many' relationship between 2 SQLObjects.

```ruby
class Cat < SQLObject
  belongs_to :owner,
    foreign_key: :ownerId,
    primary_key: :id,
    class_name: "Person"
end

oscar = Cat.find(1);
oscar.owner
```

Result

```ruby
{
  id: 1,
  name: "Oscar",
  gender: "male"
}
```
