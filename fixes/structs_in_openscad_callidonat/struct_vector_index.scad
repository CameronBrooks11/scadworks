// Struct-like pattern in OpenSCAD using vector index constants
// Response 1: https://www.reddit.com/r/openscad/comments/1sw9yb4/structs_in_openscad/

DOG_NAME = 0;
DOG_IS_GOOD = 1;

dog = ["Rex", true];

echo(dog[DOG_NAME]);
echo(dog[DOG_IS_GOOD]);

// Should return:
// ECHO: "Rex"
// ECHO: true
