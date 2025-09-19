# BU Scholar

BU Scholar is a comprehensive mobile companion application designed specifically for Bennett University students. While the current version focuses on previous year question papers, the app is being expanded to become a complete academic resource hub offering study materials, roadmaps, project resources, research papers, and much more. The intuitive interface makes it easy to find relevant content by course name, code, or description.


## Features

### Currently Implemented
- **Previous Year Question Papers**: Access mid-semester and end-semester examination papers for various courses from GitHub repository
- **Intuitive Search System**: Find resources by course name, code, or description with support for multi-word searches
- **Modern UI Design**: Clean and responsive interface built with Flutter's Material Design 3
- **PDF Viewing**: Seamlessly view PDF documents directly within the app
- **GitHub-Based Storage**: Content delivered directly from GitHub repository structure for fast access and easy updates

### Planned Features
- **Academic Roadmaps**: Structured learning paths for different programs and specializations
- **Project Repository**: Sample projects and resources for course assignments
- **Research Paper Access**: Curated collection of research papers by faculty and students
- **Study Materials**: Notes, tutorials, and additional resources for courses
- **Campus Resources**: Information about university facilities and academic support services

## Technology Stack

- **Frontend**: Flutter 3.x with Material Design 3
- **Backend**: GitHub Repository API for document storage and retrieval
- **PDF Handling**: Syncfusion Flutter PDF Viewer
- **State Management**: Flutter's built-in state management with StatefulWidgets
- **HTTP Client**: Dart's http package for API communication

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
  - `github_service.dart`: Integration with GitHub repository API for data fetching
  - `widgets/`: Reusable UI components
    - `course_card.dart`: Display card for course resources
    - `paper_button.dart`: Button component for accessing PDF papers
    - `pdf_viewer.dart`: PDF viewing component
    - `tag_chip.dart`: Tag component for categorizing resources
    - `paper_tag.dart`: Specialized tag component for paper types
  - `utils/`: Utility functions and extensions
    - `string_extensions.dart`: String manipulation utilities

## Repository Structure Setup

The application expects a `pyqs` folder in the root of the repository with the following structure:

```
pyqs/
├── computer-science-fundamentals_CSF111/
│   ├── mid_semester.pdf
│   └── end_semester.pdf
├── data-structures-and-algorithms_CSF211/
│   ├── mid_semester.pdf
│   └── end_semester.pdf
├── operating-systems_CSF372/
│   └── end_semester.pdf
└── database-management-systems_CSF212/
    ├── mid_semester.pdf
    └── end_semester.pdf
```

### Folder Naming Convention
- Course folders should follow the format: `course-name_COURSECODE`
- Course names should use hyphens instead of spaces
- Course codes should be uppercase
- Paper files should be named `mid_semester.pdf` or `end_semester.pdf`

## Backend Setup

The application uses GitHub's API to dynamically fetch course information and paper availability:

1. The app scans the `pyqs` folder for course directories
2. Each directory name is parsed to extract course name and code
3. The app checks for the presence of mid and end semester papers
4. Course cards are dynamically generated based on available papers

No additional backend setup is required - the app works directly with the GitHub repository structure.

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
