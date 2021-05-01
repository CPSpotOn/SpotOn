# SpotOn

## Table of Contents
1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview
### Description
A GPS app that allows you to travel with other together in a single instance of map. Track places where travel buddies have been to. It also allows for sharing spots in town that would have gone unnoticed by visitors otherwise. 

### App Evaluation
- **Category:** Social Networking / Location Sharing / Map
- **Mobile:** This app would be primarily developed for mobile devices. Functionality would be limited to mobile devices since it will be used on the move.
- **Story:** Finds interesting places in town where travel buddies have been to. Users can communicate with one another if they choose to. It would also have an option for reviews of the different places that were visited. Travel together as group.
- **Market:** Any individual could choose to use the app. Users would be organized into age groups to allow flow in communication.
- **Habit:** This app could be used whenever the user would like to take a stroll in their own city or town or wherever they might be traveling to.
- **Scope:** First users would connect based on their location, it could then turn into an application that could be used as a travel guide, and lastly a possible means of meeting people.

## Product Spec
### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User logs in to access previous locations and preference settings
* Map settings as well as marked visited places
* Chat window for communication with other users
* User picks desired location on map

### 2. Screen Archetypes

* Login
* Register - User signs up or log into the account
    * User will be prompted to either register their information to gain access to the app or login in case there is an existing account
* Messaging Screen - Group chat or one-on-one
    * Once location is picked user can then contact to other users who are located at the desired place or have been to the specified location
* Profile Screen
    * Allows user to upload picture if desired as well as have any information deemed interesting to share
* Map Screen
    * Allows user to pinpoint a desired location on map or travel together with others.
* Settings Screen
    * Allows user to change language, and notification settings

### 3. Navigation

**Tab Navigation** (Tab to Screen)
* Specific location on map
* Profile
* Settings

Optional:


**Flow Navigation** (Screen to Screen)
* Log-in --> Account setup if login is not available
* Specific location on map -- > Locate travel buddies
* Settings --> Toggle settings
* Profile --> Text fields to be modified 

## Wireframes
<img src="https://i.imgur.com/caokqUe.jpeg" width=800><br>

### [BONUS] Digital Wireframes & Mockups
<img src="https://i.imgur.com/70UZ3pU.png" width=800><br>

## Schema

### Models
#### Login

| Property  | Type     | Description                                                                                                             |
|-----------|----------|-------------------------------------------------------------------------------------------------------------------------|
| userId    | String   | unique id for user                                                                                                      |
| name      | String   | user full name                                                                                                          |
| username  | String   | unique username for user                                                                                                |
| email     | String   | user email address                                                                                                      |
| password  | String   | password created by user, must contain at least one uppercase, or capital letter, one lowercase and at least one number |
| createdAt | DateTime | date when user is registered                                                                                            |
| updatedAt | DateTime | date when user information is updated                                                                                   |

### Networking
#### List of newtwork calls in login screen
#### Network calls to register user to backend
``` Swift
let user = PFUser()
        user.name = nameField.text
        user.username = userNameTF.text
        user.email = emailField.text
        user.password = passwordField.text
         
        user.signUpInBackground { (success, error) in
            if let error = error{
                print("error \(error.localizedDescription)")
            }else{ //success
                self.userNameTF.text = ""
                self.nameField.text = ""
                self.emailField.text = ""
                self.passwordField.text = ""
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
            }
            
        }
```

### Loging user
#### Sending user data and getting OK response
``` Swift
Logging in:
	let userName = userNameTF.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: userName, password: password) { (user, error) in
            if user != nil{
                self.userNameTF.text = ""
                self.passwordField.text = ""
                self.performSegue(withIdentifier: "loginToFeed", sender: nil)
            }else{
                print("error \(error!.localizedDescription)")
            }
        }
```
### Sending map data
#### Map

| Property  | Type     | Description                                                                                                             |
|----------------------|---------------------|---------------------------------------------------------------------------------------------------|
| userCoordinates      | CLLocationDegrees   | coordinates representing user's location on map                                                   |
| navigationStatus     | String              | user navigation status                                                                            |
| userPinStatus        | Boolean             | user location pin status                                                                          |
| pinCoordinates       | CLLocationDegrees   | pin coordinates on map                                                                            |
| sessionStatus        | String              | network session status                                                                            |
| userPosts            | [String]            | text posted by other users                                                                        |
| userPostCoordinates  | [CLLocationDegrees] | coordinates representing users post coordinates on map                                            |

### Networking
#### List of network calls for sending map data
#### Newtwork calls to send mapm data
``` Swift
let mapObject = PFObject(classname: "MapObjects")
mapObeject["userCoordinates"] = userCoordinates
mapObeject["navigationStatus"] = navigationStatus
mapObeject["userPinStatus"] = userPinStatus 
mapObeject["pinCoordinates"] = pinCoordinates
mapObeject["sessionStatus"] = sessionStatus
mapObeject["usersPosts"] = usersPosts
mapObeject["usersPostCoordinates"] = usersPostCoordinates
mapObject.saveInBackground { (success, error) in
    if success {
        print("Map Data saved")
    } else {
        print("error \(error!.localizedDescription)")
    }
```

<img src= "https://i.imgur.com/9rFeJKq.gif" width="250">
