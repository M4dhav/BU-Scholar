# BU Scholar

BU Scholar is a comprehensive mobile companion application designed specifically for Bennett University students. While the current version focuses on previous year question papers, the app is being expanded to become a complete academic resource hub offering study materials, roadmaps, project resources, research papers, and much more. The intuitive interface makes it easy to find relevant content by course name, code, or description.


## Features

### Currently Implemented
- **Previous Year Question Papers**: Access mid-semester and end-semester examination papers for various courses
- **Intuitive Search System**: Find resources by course name, code, or description with support for multi-word searches
- **Modern UI Design**: Clean and responsive interface built with Flutter's Material Design 3
- **PDF Viewing**: Seamlessly view PDF documents directly within the app
- **Cloud-Based Storage**: Content delivered via Appwrite backend for fast access and updates

### Planned Features
- **Academic Roadmaps**: Structured learning paths for different programs and specializations
- **Project Repository**: Sample projects and resources for course assignments
- **Research Paper Access**: Curated collection of research papers by faculty and students
- **Study Materials**: Notes, tutorials, and additional resources for courses
- **Campus Resources**: Information about university facilities and academic support services

## Technology Stack

- **Frontend**: Flutter 3.x with Material Design 3
- **Backend**: Appwrite Cloud for document storage and retrieval
- **PDF Handling**: Syncfusion Flutter PDF Viewer
- **State Management**: Flutter's built-in state management with StatefulWidgets

## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or later)
- Dart SDK (compatible with Flutter version)
- An IDE (Visual Studio Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/bu_scholar.git
   cd bu_scholar
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the application
   ```bash
   flutter run
   ```

## Project Structure

- `lib/`
  - `main.dart`: Application entry point and theme configuration
  - `home_page.dart`: Main screen with search functionality and resource listing
  - `appwrite.dart`: Integration with Appwrite backend services
  - `widgets/`: Reusable UI components
    - `course_card.dart`: Display card for course resources
    - `paper_button.dart`: Button component for accessing PDF papers
    - `pdf_viewer.dart`: PDF viewing component
    - `tag_chip.dart`: Tag component for categorizing resources
    - `paper_tag.dart`: Specialized tag component for paper types
  - `utils/`: Utility functions and extensions
    - `string_extensions.dart`: String manipulation utilities

## Backend Setup

The application uses Appwrite as a backend to manage various types of academic resources. To set up your own instance:

1. Create an Appwrite account and project
2. Set up a database with collections for:
   - Courses
   - Previous Year Questions
   - Study Materials (planned)
   - Projects (planned)
   - Research Papers (planned)
   - Roadmaps (planned)
3. Configure storage buckets for document files (PDFs, etc.)
4. Update the Appwrite configuration in `lib/appwrite.dart` with your project credentials

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Developed as a comprehensive companion app for Bennett University students
- Inspired by the need for a unified platform to access academic resources and guidance
- Designed to enhance the student experience by providing easy access to course materials, roadmaps, and other academic resources
- Built with Flutter and Appwrite for cross-platform compatibility and ease of deployment
- Created with the goal of fostering academic success and supporting the Bennett University community
