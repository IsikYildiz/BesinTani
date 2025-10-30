## UC1 – Predict Food from Camera

**Actor:** User  

**Preconditions:** User is on the first page of the navigation bar after launching the application.  

**Main Success Scenario:** 
--- 
1. User taps the **Take Photo** icon at the bottom of the screen.   

2. Application takes a photo and sends it to Python server via the Internet (if user is not connected to internet an error should shown).

3. Server's model predicts the food on photo.

4. Server sends prediction result back to the application.

5. Application navigates to second page of navigation bar and displays corresponding food's information page.

<br>

**Result:** Correct food's information will be shown.
