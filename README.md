# Google Drive List

This is a learning project based on test-signet-rails code.  The purpose of the project was to learn Rails and the Google API.

Once you sign in the site will generate a list of files in your google drive. For recently modified files (30 days) it will also look at the file and count characters.

This project was an exploration into creating a system to give a teacher a dashboard into a classes work, in real-time, if they were writing in a google doc.

Currently I am not optomistic about creating this system.  My exploration with of the changes API through the Google Sandbox showed that changes were reported quite slowly.  

I also investigated the Real Time API. However, this does not give you access to google docs realtime feed. What it does is create a separate "Realtime" type document.  It appears that to get real time update info all users must be logged into a separate editor created specifically for that purpose.  My hope was to piggy back on top of the google document editor and just get updates to changes.  Rewriting an editor is not feasible for this project.

This was a good learning project and I am putting it on the shelf for now as I try other ideas.

