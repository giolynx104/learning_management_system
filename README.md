# AllHust - Learning Management System

## Project Overview

AllHust is a comprehensive Learning Management System (LMS) designed to streamline the academic processes for both lecturers and students at universities. This application aims to consolidate various academic activities into a single platform, eliminating the need for multiple systems and improving overall efficiency.

## Key Features

### For Lecturers:

- Create and manage classes for different semesters
- Take attendance for each class session
- Create assignments and surveys
- Share relevant learning materials
- Input and manage student grades
- View detailed attendance reports
- Manage absence requests

### For Students:

- Register for classes
- Mark attendance and view attendance history
- Submit assignments and participate in surveys
- Request leave of absence with documentation
- Access learning materials
- View personal academic progress

### General Features:

- Secure authentication with email verification
- Profile management with avatar customization
- Real-time notifications for academic updates
- Role-based access control (Student/Lecturer)
- Responsive design for both mobile and tablet

## Technical Stack

- **Frontend**:

  - Flutter for cross-platform development
  - Riverpod for state management
  - GoRouter for navigation
  - Dio for HTTP requests
  - Freezed for immutable state management
  - Secure Storage for token management

- **Backend**: RESTful API (not included in this repository)
- **Database**: Designed for relational database (implementation on backend)

## Current State of the Project

This repository contains the frontend codebase of the AllHust application. It is built using Flutter and is designed to work with a separate backend API. The application supports both Android and iOS platforms with the following implemented features:

- Complete authentication flow with email verification
- Profile management system
- Class management for lecturers
- Attendance tracking system
- Material sharing functionality
- Survey and assignment system
- Absence request management

## Getting Started

1. Ensure you have Flutter installed on your development machine.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Run `dart run build_runner build` to generate the necessary code.
5. Configure the API endpoint in the appropriate configuration file.
6. Run the app using `flutter run`.

## Project Structure

## Future Developments

- Integration with the backend API
- Implementation of all planned features
- Optimization for performance and user experience
- Comprehensive testing across different devices and scenarios

## Contributing

We welcome contributions to the AllHust project. Please read our contributing guidelines before submitting pull requests.

## License
