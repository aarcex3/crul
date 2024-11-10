# Path to the main source file
SRC := ./src/crul.cr
TARGET := ./bin/crul

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
crul: $(SRC)
	shards
	crystal build $(SRC) -o $(TARGET) -p -t --release
	@echo "Binary built at: $(TARGET)"
	@ls -l $(TARGET)  # Verify if the binary exists before strip
	@strip $(TARGET)
	@du -sh $(TARGET)

clean:
	rm -rf .crystal $(TARGET) $(TARGET).cr .deps .shards libs

