# Contributing to BU Scholar

Thank you for your interest in contributing to BU Scholar! This guide will help you understand how to properly organize and submit question papers.

## ⚠️ Important

**All files MUST be organized in the correct folder structure BEFORE submitting a Pull Request.**  
PRs with incorrectly organized files will not be accepted.

## 📋 Table of Contents

- [Required Directory Structure](#required-directory-structure)
- [How to Contribute](#how-to-contribute)
- [Quality Guidelines](#quality-guidelines)

## � Required Directory Structure

Your Pull Request **must** follow this exact structure:

```
pyqs/
├── subject-name_COURSECODE/
│   ├── mid_2024.pdf
│   ├── mid_2025.pdf
│   ├── end_2024.pdf
│   └── end_2025.pdf
```

### Real Examples:

```
pyqs/
├── soft-computing_CSET326/
│   ├── mid_2024.pdf
│   ├── end_2024.pdf
│   └── end_2025.pdf
├── artificial-intelligence-and-machine-learning_CSET301/
│   ├── mid_2024.pdf
│   └── end_2025.pdf
├── computer-networks_CSET207/
│   ├── mid_2023.pdf
│   ├── mid_2024.pdf
│   └── end_2024.pdf
└── operating-systems_CSET209/
    ├── end_2024.pdf
    └── end_2025.pdf
```

### Directory Naming Rules:

1. **Format:** `subject-name_COURSECODE`
2. **Subject name:**
   - Use lowercase letters
   - Replace spaces with hyphens (`-`)
   - Example: `artificial intelligence and machine learning` → `artificial-intelligence-and-machine-learning`
3. **Course code:**
   - Use UPPERCASE letters
   - Examples: `CSET326`, `EMAT102L`, `EPHY108L`

### File Naming Rules (Inside Directories):

Files inside each course directory **must** be named with exam type and year:

- ✅ `mid_2024.pdf` - Mid-term examination from 2024
- ✅ `mid_2025.pdf` - Mid-term examination from 2025
- ✅ `end_2024.pdf` - End-term examination from 2024
- ✅ `end_2025.pdf` - End-term examination from 2025

**Important Notes:**
- ⚠️ Only **mid-term** and **end-term** examinations are accepted
- ❌ **NO** quizzes, sessionals, or other exam types
- ✅ Year **must** be included in the filename
- ❌ **DO NOT** use full filenames like `soft_computing_cset326_end_2024.pdf` inside the directories

## � How to Contribute

### Step 1: Fork and Clone the Repository

### Step 1: Fork and Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/BU-Scholar.git
cd BU-Scholar
```

### Step 2: Organize Your Files

**Important:** Files MUST be organized in the correct structure manually before submitting.

Create the proper directory structure and place your files:

```bash
# Create course directory
mkdir -p pyqs/subject-name_COURSECODE

# Copy and rename your files
# Format: examtype_year.pdf
cp your_file.pdf pyqs/subject-name_COURSECODE/mid_2024.pdf
```

**Example structure to create:**
```
pyqs/
├── soft-computing_CSET326/
│   ├── mid_2024.pdf
│   ├── end_2024.pdf
│   └── end_2025.pdf
└── computer-networks_CSET207/
    ├── mid_2024.pdf
    └── end_2024.pdf
```

### Step 3: Verify the Structure

**Before submitting your PR, double-check:**

✅ Files are in `pyqs/` directory  
✅ Each course has its own directory with format: `subject-name_COURSECODE`  
✅ Files inside directories are named: `mid_YEAR.pdf`, `end_YEAR.pdf`  
✅ Year is included in all filenames
✅ Only mid and end term exams (NO quizzes or sessionals)
✅ No loose PDF files outside of course directories  
✅ PDFs are readable and properly oriented  

### Step 4: Commit and Push

```bash
git add pyqs/
git commit -m "Add question papers for [Course Names]"
git push origin main
```

### Step 5: Create a Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. In the description, include:
   - List of courses added
   - Exam types (mid/end) with years
   - Academic year

**Example PR Description:**
```
Added question papers for:
- Soft Computing (CSET326) - Mid 2024, End 2024, End 2025
- Computer Networks (CSET207) - Mid 2024, End 2024
- Operating Systems (CSET209) - End 2024, End 2025

Academic Year: 2024-25
```

## ❌ Common Mistakes to Avoid

### Wrong Structure (Will be Rejected):

```
❌ pyqs/soft_computing_cset326_end_2024.pdf
❌ pyqs/CSET326/end_2024.pdf
❌ pyqs/Soft Computing CSET326/end_2024.pdf
❌ soft-computing_CSET326/soft_computing_cset326_end_2024.pdf
❌ soft-computing_CSET326/end.pdf (missing year)
❌ soft-computing_CSET326/quiz_2024.pdf (no quizzes allowed)
❌ soft-computing_CSET326/sessional_2024.pdf (no sessionals allowed)
```

### Correct Structure (Will be Accepted):

```
✅ pyqs/soft-computing_CSET326/end_2024.pdf
✅ pyqs/soft-computing_CSET326/mid_2025.pdf
✅ pyqs/computer-networks_CSET207/mid_2024.pdf
✅ pyqs/artificial-intelligence-and-machine-learning_CSET301/end_2024.pdf
```

## 📊 Quality Guidelines

### File Requirements:

✅ **DO:**
- Use clear, readable scans
- Ensure PDFs are properly oriented
- Keep file sizes reasonable (compress if needed)
- Verify the PDF opens correctly
- Use official course names and codes
- **Organize files in correct directory structure BEFORE submitting PR**

❌ **DON'T:**
- Submit loose PDF files without proper directory structure
- Upload blurry or unreadable scans
- Upload duplicate papers
- Use incorrect course codes or directory names

### Content Guidelines:

- Only upload **past year question papers** (PyQs)
- **Only mid-term and end-term examinations** are accepted
- **NO quizzes, sessionals, or other exam types**
- Ensure papers are from Bennett University
- Verify the course code matches the current curriculum
- Year must be included in all filenames

## ✅ PR Checklist

Before submitting your Pull Request, verify:

- [ ] All files are in the `pyqs/` directory
- [ ] Each course has its own directory: `subject-name_COURSECODE`
- [ ] Directory names use lowercase subject names with hyphens
- [ ] Directory names use UPPERCASE course codes
- [ ] Files inside directories are named: `mid_YEAR.pdf`, `end_YEAR.pdf`
- [ ] Year is included in all filenames (e.g., 2024, 2025)
- [ ] Only mid and end term exams (NO quizzes or sessionals)
- [ ] No files are directly in `pyqs/` (must be in subdirectories)
- [ ] All PDFs are readable and correctly oriented
- [ ] PR description includes list of courses added

## 🤝 Additional Support

If you encounter any issues:

1. Check the [README.md](README.md) for general project information
2. Review the [directory structure requirements](#required-directory-structure) carefully
3. Open an issue on GitHub describing your problem

## 📞 Contact

For questions or clarifications:
- Open an issue on GitHub
- Contact the maintainer: M4dhav

---

Thank you for contributing to BU Scholar and helping fellow students! 🎓✨
