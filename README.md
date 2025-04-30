# GPA-Calculator-Assembly-emu8086
A command-line GPA calculator written in x86 Assembly (MASM/TASM) that accepts letter grades and credit hours, computes GPA with validation, and displays the result with formatted output. Ideal for learning assembly-level input/output and arithmetic.

# GPA Calculator (x86 Assembly)

This is a command-line GPA Calculator written in x86 Assembly (MASM/TASM compatible). It takes user input for subjects, letter grades (with + or - modifiers), and credit hours, then calculates the GPA with accurate handling of decimal values.

## Features

- Supports GPA calculation for up to 9 subjects
- Accepts letter grades with modifiers: A+, A, A-, ..., F
- Validates both grade format and credit hour ranges (1 to 4)
- Accurately computes GPA including decimal point (tenths place)
- Clears screen and formats output for a clean user experience
- Compatible with EMU8086, MASM, and TASM assemblers

## Input Validation

This project includes strong input validation:
- **Grade Validation**: Ensures only valid letter grades (A-F) with optional `+` or `-` modifiers are accepted. Invalid input triggers a re-prompt.
- **Credit Hour Validation**: Accepts only numeric values from 1 to 4. Invalid entries outside this range prompt the user again.
- **Point Value Handling**: GPA values are handled in fixed-point format by storing integer and decimal parts separately. This ensures the final output (e.g., `3.7`, `2.3`) is mathematically correct, even after credit hour multiplication and total GPA calculation.

## How to Run

### ▶ Using MASM or TASM
1. Open DOSBox or command prompt with MASM/TASM set up.
2. Assemble and link the program:
   ```bash
   tasm gpa.asm
   tlink gpa.obj
   gpa.exe

### ▶ On EMU8086

    Open EMU8086 IDE.
    Paste the code into a new .asm file.
    Click Compile and Run.
## Notes
1. Decimal accuracy is achieved through fixed-point arithmetic (integer + fractional byte).
2. The screen is cleared using INT 10h with background and text attributes.
3. This project handles invalid input more robustly than many other similar GPA calculators on GitHub.


## License

This project is licensed under the **Creative Commons Attribution-NoDerivatives 4.0 International License**.

You are free to:

- Use, copy, and distribute the code for **any purpose**, including commercial use, as long as you **do not modify** it.

However, you may **not**:

- Modify, adapt, or create derivative works based on this project.
- Distribute the modified version.

### CC BY-ND License

The terms of the license are as follows:

- **Attribution**: You must give appropriate credit, provide a link to the license, and indicate if changes were made. However, you may not suggest that the licensor endorses you or your use.
  
- **NoDerivatives**: If you remix, transform, or build upon the material, you may not distribute the modified material.

Full text: [https://creativecommons.org/licenses/by-nd/4.0/](https://creativecommons.org/licenses/by-nd/4.0/)

