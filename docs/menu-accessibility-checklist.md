MENU ACCESSIBILITY CHECKLIST
==============================

ALWAYS perform these steps BEFORE implementing keyboard navigation for a menu:


1. UNDERSTAND STRUCTURE
---------------------
- How is the menu structured? (Linear, grid, hierarchical)
- What elements exist? (Buttons, selection boxes, sliders, input fields)
- What parent-child relationships exist?


2. ANALYZE INTERACTION PATTERNS
---------------------------------
- How is each element activated? (Click, double-click, hover)
- How are values changed? (scrollBy, increment, toggle)
- What events/handlers already exist? (clickReleased, scrollBy, keyPressed)

IMPORTANT: Reuse existing methods, don't reinvent!


3. CHECK EXISTING ACCESSIBILITY SYSTEMS
------------------------------------------
- Is there already a FocusManager, IFocusable, or similar?
- Which elements are already registered?
- How are announcements already made? (ScreenReader class)


4. DEFINE NAVIGATION CONCEPT
-------------------------------
- Up/Down: Navigate between elements
- Left/Right: Change values (for selection boxes) or navigate within groups
- Enter: Activate/Open
- Escape: Back/Close


5. CHECK ANNOUNCEMENT TEXTS
---------------------
- Are all labels meaningful natural language expressions?
- Not empty, not "item123", not context-free
- Does the announcement contain the current value/state?


6. TEST INCREMENTALLY
----------------------
- Test after each change, not all at once
- Make one element fully functional first, then the next


EXAMPLE WORKFLOW
=================

Assume a menu has the following elements:
- 3 buttons (Start, Options, Exit)
- 1 selection box for difficulty (Easy, Medium, Hard)
- 1 slider for volume

Step 1: Analyze code
- Buttons use clickReleased() for activation
- Selection box uses scrollBy() for value change
- Slider uses setValue() with mouse position

Step 2: Find existing systems
- FocusManager already exists
- IFocusable interface available
- ScreenReader::speakInterruptible() for announcements

Step 3: Implement
- Buttons: Implement IFocusable, simulateClick() calls clickReleased()
- Selection box: onArrowKey() calls scrollBy()
- Slider: onArrowKey() calls setValue() with +/- 10%

Step 4: Test
- Test each button individually
- Selection box: Left/Right changes value?
- Slider: Left/Right changes value?
- Announcements correct?
