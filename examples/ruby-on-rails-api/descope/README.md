# Descope Ruby On Rails API Example

Rails-React Sample app with Descope Auth
Add Descope's Ruby SDK to add authentication to a Rails 7 + React.js app. The project will feature multiple pages, protected routes, and logout functionality

## ⚙️ Setup
 
1. Install dependencies:

    ```
    bundle install
    ```

2. Client Setup

    Create a ```.env``` file in the root directory of the `client` folder and add your Descope [Project ID](https://app.descope.com/settings/project) in the file:
    
    ```toml
    REACT_APP_PROJECT_ID="YOUR_DESCOPE_PROJECT_ID"
    ```

    > **NOTE**: If you're running your flask server on a different port than 3000, change the ```"proxy":"http://127.0.0.1:3000/"``` value to wherever your server is hosted. You can edit the proxy value in your client package.json file.

3. Server Setup

    Since this app also showcases roles, it will require you to set them up in the Descope Console.
    
    - Create two different [roles]((https://app.descope.com/authorization)) called "teacher" and "student" <br>
      - Create a ```.env``` file in the server folder and add your project id in the file:
    ```toml
    PROJECT_ID="YOUR_DESCOPE_PROJECT_ID"
    ```

## 🔮 Running the Application

To run the server:

```
./bin/dev 
```

## 📁 Folder Structure

- Server: the server folder contains the rails app and server that will handle session validation
- React App in the `app/javascript/components` folder

## ⚠️ Issue Reporting

For any issues or suggestions, feel free to open an issue in the GitHub repository.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

