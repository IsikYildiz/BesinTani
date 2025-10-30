## UC2 – Predict Food from Gallery

**Actor:** User  

**Preconditions:** User is on the first page of the navigation bar after launching the application.  

**Main Success Scenario:** 
--- 
1. User taps the **Gallery** icon at the top right of the screen.   

2. Users gallery will be shown.

3. User selects a photo from their gallery (If user simply closes the gallery then user should be sent back to first page).

4. Application sends the selected photo to Python server via the Internet (if user is not connected to internet an error should shown).

5. Server's model predicts the food on photo.

6. Server sends prediction result back to the application.

7. Application navigates to second page of navigation bar and displays corresponding food's information page.

<br>

**Result:** Correct food's information will be shown.
