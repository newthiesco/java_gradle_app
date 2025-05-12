 Create wrapper in a clean temp folder, then copy it

Create a new folder to bootstrap Gradle wrapper:

mkdir ~/temp-gradle-wrapper
cd ~/temp-gradle-wrapper

gradle wrapper --gradle-version 7.6.4

This should succeed because there's no build.gradle to conflict with plugins.

You should now see:

gradlew
gradlew.bat
gradle/wrapper/gradle-wrapper.properties
gradle/wrapper/gradle-wrapper.jar

✅ Now Back in Your Project
cd ~/Documents/java_gradle_app/
./gradlew clean build

If this works, then your Jenkins pipeline should also work now.

✅ Fix: Commit the wrapper files to Git

From your local machine:

cd ~/Documents/java_gradle_app
git add gradlew gradlew.bat gradle/wrapper/gradle-wrapper.jar gradle/wrapper/gradle-wrapper.properties
git commit -m "Add Gradle wrapper files"
git push

Then re-run your Jenkins pipeline.

there was no .gitignore but the .jar file was ignored by default.
Check if gradle-wrapper.jar is already ignored by global Git settings

Git can ignore files globally (not just per-repo). Run this to see if any global rules are in play:
git config --get core.excludesfile
Look for any of these lines:
*.jar
gradle-wrapper.jar
gradle/wrapper/
If you find such a line, either remove it or add an exception like:

!gradle/wrapper/gradle-wrapper.jar

Then add, commit, and push again.

