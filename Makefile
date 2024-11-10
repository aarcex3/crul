# Path to the main source file
SRC := ./src/main.cr
TARGET := ./bin/crul.cr
# Default target to run tests, lint checks, and formatting
check-all: format lint test

# Run tests
test:
	crystal spec -v -p -t --color

# Run linter with style and lint checks only
lint:
	./bin/ameba --only Style,Lint

# Format the code using crystal tool
format:
	crystal tool format

# Build the project with the source file
build:
	crystal build $(SRC) -o $(TARGET) -p -t --release 

# The all target, which builds the project using 'crul'
all: crul

# Build the crul project, install dependencies, and link with static libraries
crul: src/main.cr 
	shards
	crystal build $(SRC) -o $(TARGET) -p -t --release 
	@strip crul
	@du -sh crul

# Clean up build artifacts
clean:
	rm -rf .crystal crul .deps .shards libs

