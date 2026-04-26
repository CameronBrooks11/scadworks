# Struct in OpenSCAD - Callidonat on Reddit

Response to [this Reddit post](https://www.reddit.com/r/openscad/comments/1sw9yb4/structs_in_openscad/).

## Response 1

Yes that won't work, in OpenSCAD values are immutable (cannot be changed once assigned). You can achieve your goal using vector access:

```scad
DOG_NAME = 0;
DOG_IS_GOOD = 1;

dog = ["Rex", true];

echo(dog[DOG_NAME]);
echo(dog[DOG_IS_GOOD]);

DOG_NAME = 0;
DOG_IS_GOOD = 1;
dog = ["Rex", true];
echo(dog[DOG_NAME]);
echo(dog[DOG_IS_GOOD]);
// should return:
// ECHO: "Rex"
// ECHO: true
```

## Response 2

You can further improve this using vectors + functions to construct the record as a fix-position vector:

```scad
PERSON_NAME = 0;
PERSON_AGE  = 1;

function person(name, age = 42) = [name, age];

function person_name(p) = p[PERSON_NAME];
function person_age(p)  = p[PERSON_AGE];

// "Update" by returning a new record, not mutating the old one.
function person_with_age(p, age) =
    [person_name(p), age];

people = [
    person("Bob", 20),
    person("Alice", 30),
    person("Fred", 0),
    person("Ann", 40),
    person("Jon")
];

for (p = people)
    echo(str(person_name(p), " is ", person_age(p)));

s = person("Sean", 50);
echo(person_name(s));

sp = person_with_age(s, 51);
echo(person_age(sp));PERSON_NAME = 0;
PERSON_AGE  = 1;

function person(name, age = 42) = [name, age];

function person_name(p) = p[PERSON_NAME];
function person_age(p)  = p[PERSON_AGE];

// "Update" by returning a new record, not mutating the old one.
function person_with_age(p, age) =
    [person_name(p), age];

people = [
    person("Bob", 20),
    person("Alice", 30),
    person("Fred", 0),
    person("Ann", 40),
    person("Jon")
];

for (p = people)
    echo(str(person_name(p), " is ", person_age(p)));

s = person("Sean", 50);
echo(person_name(s));

sp = person_with_age(s, 51);
echo(person_age(sp));

// Should return:
// ECHO: "Bob is 20"
// ECHO: "Alice is 30"
// ECHO: "Fred is 0"
// ECHO: "Ann is 40"
// ECHO: "Jon is 42"
// ECHO: "Sean"
// ECHO: 51
```

## Response 3

There's also experimental object() support exists only in dev snapshots, but I cant speak confidently on that since I haven't used it myself yet. A good example of what you are talking about in the wild is nopscadlib - if you look here:
https://github.com/nophead/NopSCADlib/tree/master/vitamins
You will see the pattern:
`part.scad`
`parts.scad`
Where the source geometry is in part.scad and the plural parts.scad has the different realization parameters.
