# Pawpal 🐾 

**Pawpal** is a mobile-based pet adoption and donation platform designed to connect stray animal rescuers, pet seekers, and kind-hearted donors. The system adopts a decoupled architecture with Flutter for the cross-platform mobile frontend, PHP for the backend providing RESTful APIs, and MySQL for data storage.

> Fully deployed and accessible globally via Jomhosting. **This project is for educational purposes.**

---

## 📋 Project Overview
The goal of this project is to create a seamless platform for pet welfare.
* **For Users:** Submit pet listings with photos and location, edit details and track status.
* **For Rescuers/Owners:** Submit pets for adoption, donation, or emergency rescue/help.

---

## 🛠️ Tech Stack
* **Frontend:** Flutter(Dart)
* **Backend:** PHP (Hosted on cPanel - Jomhosting)
* **Database:** MySQL (Managed via phpMyAdmin)
* **Payment Gateway:** Billplz (Sandbox mode)
* **Key Libraries:** `setState`(StatefulWidgets), `geolocator`,`geocoding`, `http`, `image_cropper`, `image_picker`, `shared_preferences`, `webview_flutter`.

---

## ⚙️ Project Setup

### 1. Domain & Hosting
* Configured via **Jomhosting cPanel**.
* **SSL/TLS:** AutoSSL enabled via cPanel to ensure secure `https` connections.
* **DNS:** Pointed domain name to hosting servers.

### 2. Database Configuration
* Database Name: `youcapfu_pawpaldb`
* Tables Implemented:
    * `tbl_users`: User credentials and credit balances.
    * `tbl_pets`: Pet profiles and status information.
    * `tbl_adoptions`: Records of adoption applications.
    * `tbl_donations`: Transaction logs for monetary and item donations.

### 3. Backend Deployment
* PHP API scripts uploaded to `/pawpal/api/`.
* Directory permissions configured for image storage:
    * `/api/uploads/`

### 4. Billplz Integration
* API Keys and Collection IDs configured within the Billplz sandbox for secure payment processing.

---

## ✨ Features

### 1. User Authentication
* Login
* Registration
* Profile Management

### 2. Pet Listing
* View available pets with search (by name) and filter (by type: Cat, Dog, etc.) capabilities

### 3. Pet Submission
* Upload pet details (Name, Age, Gender, Health, etc.)
* Multi-image upload with cropping
* Auto-location detection using GPS

### 4. Adoption System
* View pet details
* Submit adoption requests with contact info and reasoning

### 5. Donation Module
* Donate specific items (Food/Medical)
* **Monetary Donation**: Top-up user wallet via Billplz and donate to specific pets
* View donation history

### 6. E-Wallet
* Integrated wallet system with top-up history and receipt generation

---

## 🛠️ API Usage Reference

All API requests are sent to https://youcanyouup.com.my/pawpal_yeoh/pawpal/api/

| API NAME | METHOD | PARAMS | DESCRIPTION |
|:---|:---:|:---|:---|
| `dbconnect.php` | - | - | Establishes connection to the hosting server database (Jomhosting). |
| `register.php` | POST | email, password, name, phone | Registers a new user account. |
| `login.php` | POST | email, password | Authenticates user credentials. |
| `submit_pet.php` | POST | userid, petname, pettype, gender, age, category, health, description, latitude, longitude, images | Submits a new pet listing with full details and images. |
| `get_my_pets.php` | GET | search (optional) | Retrieves a list of pets, with optional search filtering. |
| `edit_pet.php` | POST | petid, userid, petname, images, etc. | Updates an existing pet listing. |
| `delete_pet.php` | POST | userid, petid | Deletes a pet listing from the database. |
| `submit_adoption_request.php` | POST | userid, petid, contact_info, reason_adopt | Submits a request to adopt a pet. |
| `get_my_adoptions.php` | GET | userid | Retrieves adoption requests related to the user (as adopter or owner). |
| `delete_adoption.php` | POST | adoption_id | Deletes/Cancels an adoption request. |
| `submit_donations.php` | POST | userid, petid, amount, donationType, description | Submits a donation record (deducts wallet if money). |
| `get_my_donations.php` | GET | user_id | Retrieves donation history for the user (as donor or recipient). |
| `payment.php` | GET | userid, amount (or money), email, mobile, name | Initiates a Billplz payment process. |
| `payment_update.php` | GET | billplz array, userid, money | Callback URL to verify payment and update user wallet. |
| `get_user_details.php` | GET | userid | Retrieves profile details for a specific user. |
| `update_user_profile.php` | POST | user_id, user_name, user_phone, user_image (base64) | Updates user profile details and profile picture. |

---

## 💡 Troubleshooting & Notes

### Remember
* API URLs must match your hosting domain
* Ensure cPanel hosting is running
* Checking image url store in the right place or not else is bug happening

### Maintenance Commands
If you encounter build issues or UI inconsistencies, run:
```bash
flutter clean
flutter pub get

