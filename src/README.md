# Display a random number

What it does? It prints a random number between two points that are provided by two parameters on the URL:

 * min (int)
 * max (int)
 
Default is 0 and 12, respectively.

This is not something fancy, but it's something.

Debug mode for Flask can be provided by using `DEBUG_MODE=True` environment variable, which defaults to `False`.

# TODO

Minor TODO, outside the scope of this sandbox, is to cache the first layer in the Dockerfile if it's possible, to support changing only source code and not pip-installed libraries.