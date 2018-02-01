.PHONY: clean build xcode

# Build the project
build:
	swift build

# Clean local build artifacts
clean:
	rm -rf .build

# Generate Xcode project
xcode:
	swift package generate-xcodeproj
