## UC6 – Add a Food to a Daily Intake List
**Actor:** User  

**Preconditions:** User is on the first page of the navigation bar after launching the application. 

**Main Success Scenario:** 
--- 

1. User navigates to third page of navigation bar (page should shown todays intake list).

2. (Optional) User taps the **calendar icon** at the top of right the screen.

    - Application shows a calendar.

    - User selects a date from the calendar.

    - Application displays selected date's daily intake list. When empty "this list is empty" message is shown.

3. User taps the **add icon** at the bottom right of the screen.

4. A pop-up is shown where user can select the food they want to add.

5. User searches the food by writing its name onto search field.

6. Application displays matching food items in a dropdown list beneath the search field. 

7. User selects the food they want to add.

8. (Optional) User can change calorie of the food they selected.

9. User taps **confirm** button.

10. Food is added to daily intake list.

**Alternative Scenario:**
---
7a. User selects the "other" option.

    - User must enter the calorie themselves.

9a. If the user cancels the operation, the pop-up closes without changes.  
  
<br>

**Result:** Food that user selected gets added to daily intake list.
