# catcafe

A Cozy Flutter E-Commerce Experience for Coffee & Cat Lovers

Cat Cafe is a Flutter-based e-commerce mobile application designed to combine the experience of shopping for coffee products with a cozy cat-inspired visual identity.

The application provides a complete shopping experience for customers, starting from onboarding and authentication, through browsing products and categories, managing favorites and cart items, and ending with checkout and order tracking.

The project also includes a dedicated Admin Panel that allows administrators to manage products, categories, and customer orders while controlling the status of each order.

The main goal of the project was not only to build the required functionality, but also to create a consistent, polished, and production-oriented mobile experience with a clear design system and reusable components.

📸 Screenshot — ضعي هون صورة حلوة للـ Home Screen كأول صورة بالمشروع.

2. Project Overview
Project Overview

Cat Cafe was developed as a complete Flutter e-commerce application with two main experiences:

Customer Experience
Admin Experience

Customers can browse the available products, search and filter products, view product details, add products to favorites or cart, complete checkout, and follow their orders.

Administrators have a separate interface where they can monitor the store, manage products and categories, view customer orders, and update order statuses.

The application uses Firebase as the main backend infrastructure and Firestore as the database for users, products, categories, carts, favorites, and orders.

📸 Screenshot — ضعي صورة Home + صورة Admin Dashboard جنب بعض إذا README بيدعمهم، أو صورة Home فقط هون.

3. Main Features
Main Features
👤 Customer Features
User Registration and Login
Onboarding experience
Browse products
Browse products by categories
Product search
Product details
Product images
Favorites management
Shopping cart
Quantity management
Checkout
Delivery address
Order creation
Order history
Order cancellation
Order status tracking
User profile management
Profile image upload

📸 Screenshot — هون حطي Screenshot فيه Home Screen أو Product Details.

🛠️ Admin Features
Admin authentication and role-based access
Admin Dashboard
Store statistics
Product management
Add products
Edit products
Delete products
Category management
Add categories
Delete categories
View all customer orders
Filter orders by status
View order details
Update order status

📸 Screenshot — هون حطي صورة Admin Dashboard.

📸 Screenshot — بعدها صورة Admin Orders Screen.

4. Application Flow
Application Flow

The application follows a complete e-commerce flow:

Onboarding → Authentication → Home → Product Browsing → Product Details → Favorites / Cart → Checkout → Order Creation → Order Tracking

For administrators, the flow is:

Admin Login → Admin Dashboard → Products / Categories / Orders → Order Status Management

This structure separates the customer experience from the administrative experience while keeping both connected to the same Firebase backend.

📸 Screenshot — هون ممكن تحطي 3 صور صغيرة: Login → Home → Checkout.

5. Technology Stack
Technology Stack
Frontend
Flutter
Dart
Material Design
Reusable Flutter Widgets
Backend & Database
Firebase Authentication
Cloud Firestore
Image Management
Cloudinary

Cloudinary is used to store and manage product and profile images instead of storing the images directly in Firebase Storage.

Development Tools
Android Studio
Visual Studio Code
Git
GitHub
6. Project Structure
Project Structure

The project is organized into separate folders according to the application's responsibilities.

lib/admin

Contains the screens and functionality related to the Admin experience.

add_product_screen.dart
admin_dashboard_screen.dart
admin_main_screen.dart
admin_orders_screen.dart
categories_screen.dart
edit_product_screen.dart
lib/features

Contains the main application features.

adoption
adoption_screen.dart
auth
login_screen.dart
signup_screen.dart
cart
cart_screen.dart
cart_item_model.dart
cart_service.dart
checkout
checkout_address_screen.dart
checkout_model.dart
checkout_service.dart
onboarding
onboarding_screen.dart
onboarding_page.dart
profile
profile_screen.dart
lib/services

Contains application services such as:

Cloudinary service
Order service
lib/user

Contains customer-related screens such as:

Favorites
My Orders
Product Details
User Home
User Main Screen
lib/widgets

Contains reusable UI components such as:

App Button
App Logo
App Text Field
Empty State
Product Card
UI Kit

📸 Screenshot — هون حطي Screenshot للـ Project Structure من Android Studio، زي الصور اللي بعثتيهم.

7. Design System
Design System

One of the important parts of the project is the centralized design system.

Instead of defining colors, spacing, typography, shadows, and border radii separately inside every screen, the application uses shared design files under:

lib/core/theme

The main design files are:

app_colors.dart
app_radius.dart
app_shadows.dart
app_spacing.dart
app_text_styles.dart
app_theme.dart

This approach helps maintain visual consistency throughout the application and makes the UI easier to maintain and update.

AppColors

Contains the application's shared color palette and prevents repeatedly defining the same colors in different screens.

AppRadius

Contains the shared border-radius values used across cards, buttons, inputs, and other UI elements.

AppShadows

Contains the shared shadow definitions used to create depth and visual hierarchy.

AppSpacing

Contains the shared spacing values used for consistent padding, margins, and gaps.

AppTextStyles

Contains the shared typography styles used for headings, body text, labels, and other text elements.

AppTheme

Combines the different design-system elements into the application's global Flutter Theme.

This allows standard Flutter components to automatically follow the application's visual identity.

📸 Screenshot — هون حطي Screenshot من فولدر core/theme مفتوح، زي الصورة الأولى اللي بعثتيها.

8. Reusable Components
Reusable UI Components

The application also uses reusable widgets to avoid repeating the same UI structure across different screens.

Examples include:

AppButton

A shared button component used throughout the application to provide a consistent button appearance and behavior.

AppTextField

A reusable input component used for forms such as Login, Sign Up, Profile, and other input screens.

ProductCard

A reusable product component responsible for displaying products consistently across the application.

EmptyState

A reusable component used when there is no available data, such as an empty cart, favorites list, or orders list.

AppLogo

A shared logo component used to maintain a consistent Cat Cafe brand identity.

This reusable-component approach makes the UI more consistent and reduces duplicated interface code.

📸 Screenshot — هون حطي Screenshot من فولدر widgets.

📸 Screenshot — بعدها حطي صورة Home فيها Product Cards واضحة.

9. Firebase Architecture
Firebase Architecture

Firebase is used as the main backend infrastructure of Cat Cafe.

The application uses Firebase Authentication for user authentication and Cloud Firestore for storing and retrieving application data.

The main Firestore collections are:

users
products
categories
orders

Users also have their own subcollections for:

cart
favorites

This structure allows the application to keep customer-specific data separated while maintaining a centralized store database.

10. Authentication & User Roles
Authentication and User Roles

The application supports different user roles.

The user's role is stored in the user's Firestore document.

For example, an administrator has:

role: admin

The application uses this role to determine whether the authenticated user has access to administrative functionality.

The Firestore Security Rules provide an additional security layer by checking the authenticated user's UID and role before allowing sensitive operations.

This means that the Admin interface is not only separated visually, but administrative operations are also protected at the database level.

📸 Screenshot — هون حطي Screenshot من Firebase Authentication أو users collection إذا مسموح تعرضيها بالفيديو/README.

11. Firestore Security Rules
Firestore Security Rules

Security Rules are used to control what authenticated users and administrators are allowed to do.

Users

A user can access and update their own profile.

Users can also manage their own:

Cart
Favorites
Products

Authenticated users can read products.

Only administrators can create, update, or delete products.

An exception exists for checkout, where a normal user is allowed to decrease product stock only under controlled conditions defined in the Security Rules.

Categories

Authenticated users can read categories.

Only administrators can create, update, or delete categories.

Orders

Users can read their own orders.

Administrators can read all orders.

Users can create orders only for themselves, and a newly created order must start with the pending status.

Administrators can update orders.

Users are only allowed to cancel their own pending orders under the conditions defined in the rules.

Only administrators can delete orders.

This provides an additional security layer between the application and the Firestore database.

📸 Screenshot — هون حطي Screenshot من Firestore Rules، خصوصًا جزء orders وproducts.

12. Admin Order Status Management
Admin Order Status Management

The Admin Orders screen retrieves orders from the orders collection in Firestore and displays them according to their creation date.

Each order contains a status such as:

Pending
Processing
Out for Delivery
Delivered
Cancelled

The Admin can filter orders by their current status.

Inside each order card, the current status is displayed and the administrator can select a new status using the dropdown menu.

When the administrator selects a new status, the application updates the corresponding order document in Firestore.

The update changes the status field and also updates updatedAt using a server timestamp.

Because the Orders screen uses a Firestore stream, the UI can automatically reflect the updated order data after the Firestore document changes.

📸 Screenshot — هون حطي صورة Admin Orders فيها الـ Status واضح.

📸 Screenshot — بعدها صورة الـ Dropdown وهو مفتوح والحالات ظاهرة.

13. Checkout Process
Checkout Process

The checkout process connects the customer's cart with the order system and product stock.

The process can be summarized as:

Cart → Checkout → Address → Stock Validation → Order Creation → Stock Update → Cart Cleanup

Before completing the order, the application validates the available product stock.

The checkout operation is handled using a Firestore transaction to keep the related database operations consistent.

The process includes:

Reading the products involved in the cart.
Checking the current stock.
Making sure the requested quantities are available.
Creating the order.
Decreasing the product stock.
Removing the purchased cart items.

This prevents the application from creating an order while ignoring the current product stock.

14. Checkout Security
Checkout Security

The Firestore Security Rules also protect the stock update during checkout.

A normal user is not allowed to randomly modify product stock.

The rules verify that:

Only the quantity field is changed.
The new quantity is lower than the previous quantity.
The quantity being decreased matches the quantity stored in the user's cart.
The cart item exists before the operation.
The cart item is removed as part of the same operation.

This prevents users from manually changing product stock outside the intended checkout process.

This combination of application-side validation and Firestore Security Rules provides stronger protection for the checkout process.

15. Order Lifecycle
Order Lifecycle

An order follows a defined lifecycle:

Pending → Processing → Out for Delivery → Delivered

An order can also become:

Pending → Cancelled

The customer can cancel an order only while it is still pending.

The administrator is responsible for moving the order through the different fulfillment stages.

This creates a clear separation between customer actions and administrative order management.

📸 Screenshot — هون حطي صورة فيها Order Status أو Admin Dashboard اللي فيه Order Lifecycle.

16. Product Management
Product Management

Administrators can manage the products available in the store.

The Admin interface supports:

Adding products
Editing products
Deleting products
Managing product information
Managing product quantity
Assigning products to categories
Managing product images

Product information is stored in the products collection in Firestore.

Product images are managed through Cloudinary, while the image URL is stored with the product data.

📸 Screenshot — هون حطي Add Product Screen.

📸 Screenshot — بعدها Edit Product Screen.

17. Category Management
Category Management

Categories are stored in the categories collection in Firestore.

Administrators can add new categories and delete existing categories through the Categories screen.

The application also checks whether a category already exists before adding it, helping prevent duplicate category names.

Regular authenticated users can read categories, while only administrators are allowed to modify them.

📸 Screenshot — هون حطي Categories Screen.

18. Cart & Favorites
Cart and Favorites

Each authenticated user has their own cart and favorites collections.

The cart allows customers to:

Add products
Increase quantity
Decrease quantity
Remove products
Continue to checkout

Favorites allow customers to save products they are interested in and access them later.

Both features are associated with the authenticated user's UID, which keeps each user's data separated from other users.

📸 Screenshot — هون حطي Cart Screen.

📸 Screenshot — بعدها Favorites Screen.

19. User Profile
User Profile

The Profile screen allows users to manage their personal information.

Users can update:

Name
Age
Phone
Bio
Profile image

Profile data is stored in the user's document inside the users collection.

Profile images are uploaded using Cloudinary, and the resulting image URL is stored in Firestore.

The profile screen also provides the logout functionality.

📸 Screenshot — هون حطي Profile Screen.

20. Error, Loading & Empty States
Loading, Error and Empty States

The application handles different UI states instead of displaying a blank screen when data is unavailable.

Examples include:

Loading indicators while Firebase data is being retrieved
Error messages when data cannot be loaded
Empty cart states
Empty favorites states
Empty orders states
Empty search results

These states provide clearer feedback to the user and make the application feel more complete and production-oriented.

📸 Screenshot — إذا عندك Screenshot للـ Empty Cart أو No Orders، حطيه هون.

21. UI/UX Approach
UI/UX Approach

The visual identity of Cat Cafe was designed around a cozy coffee-shop atmosphere combined with a subtle cat-inspired identity.

The design focuses on:

Warm colors
Soft rounded cards
Consistent spacing
Clear typography
Subtle shadows
Consistent buttons and input fields
Reusable product components
Clear visual hierarchy
Simple and intuitive navigation

The goal was to create an interface that feels modern and professional while still maintaining the unique Cat Cafe personality.

22. Why a Shared Design System?
Why a Shared Design System?

As the number of screens increased, repeating UI values across every screen would make the project harder to maintain.

For this reason, shared design files and reusable widgets were introduced.

Instead of defining the same color, radius, spacing, or text style repeatedly, the application centralizes these values.

This provides three main benefits:

Consistency
Different screens follow the same visual language.
Maintainability
Design changes can be managed from centralized locations.
Reusability
Common UI components can be reused across multiple screens.
23. Architecture Overview
Architecture Overview

The project separates the application into different responsibilities.

The screens are responsible for displaying the user interface and handling user interactions.

Services are responsible for operations such as cart management, orders, and image uploading.

Models represent structured application data such as cart items and checkout information.

Firebase provides authentication and persistent database storage.

The shared theme and widgets provide the common visual foundation of the application.

This separation makes the project easier to understand, maintain, and extend.

24. Complete User Journey
Complete Customer Journey

A typical customer journey through Cat Cafe is:

The user opens the application.
The user goes through the onboarding experience.
The user creates an account or logs in.
The user reaches the Home screen.
The user browses or searches for products.
The user opens a product to view its details.
The user can add the product to favorites or cart.
The user reviews the cart.
The user proceeds to checkout.
The user provides the delivery address.
The application validates product stock.
The order is created with a Pending status.
The purchased quantities are removed from product stock.
The purchased cart items are removed.
The customer can view the order in My Orders.
The administrator processes the order.
The administrator updates the order status.
The customer can see the updated order status.

📸 Screenshot — هون الأفضل تحطي 4 صور مرتبة:
Onboarding → Home → Cart → My Orders

25. Admin Journey
Complete Admin Journey

The administrator has a separate workflow:

The administrator logs in using an admin account.
The application identifies the user's role.
The administrator enters the Admin interface.
The Admin Dashboard displays store statistics.
The administrator can manage products.
The administrator can manage categories.
The administrator can view customer orders.
The administrator can filter orders by status.
The administrator can open an order and review its information.
The administrator can update the order status.
The new status is stored in Firestore.
The customer can then see the updated order status.

📸 Screenshot — هون حطي Admin Dashboard.

📸 Screenshot — بعدها Admin Orders.

26. Project Highlights
Project Highlights

Some of the main aspects that make Cat Cafe more than a basic Flutter application are:

Complete e-commerce flow
Firebase Authentication
Firestore database integration
Firestore Security Rules
Role-based Admin functionality
Product and category management
Cart and favorites
Checkout and stock validation
Order lifecycle management
Real-time Firestore updates
Cloudinary image management
Centralized design system
Reusable UI components
Loading, error, and empty states
Structured project organization
Customer and Admin experiences
27. Demo Video
Demo Video

The project demonstration focuses on the technical decisions behind the application rather than only showing the final interface.

The demonstration covers four main areas:

1. Firestore Security Rules & Admin Permissions

Explaining how the database identifies authenticated users and administrators and how permissions are controlled for products, categories, and orders.

2. Admin Order Status Management

Explaining how the Admin selects an order status from the Flutter interface and how the selected status is updated in Firestore.

3. Checkout Process — Concept

Explaining the checkout flow, stock validation, order creation, stock reduction, and cart cleanup.

4. Checkout Process — Code

Explaining how the checkout process is implemented in the Flutter code and how it communicates with Firestore.

28. Final Project Summary
Conclusion

Cat Cafe is a complete Flutter e-commerce application that combines a customer shopping experience with a dedicated administrative system.

The project was developed with a focus on both functionality and maintainability.

The application integrates Flutter, Firebase Authentication, Cloud Firestore, Cloudinary, reusable widgets, centralized design tokens, and Firestore Security Rules to provide a structured and secure e-commerce experience.

The project also demonstrates how different parts of a mobile application work together:

UI → Flutter Logic → Services → Firebase → Firestore Security Rules

This structure allows the application to provide a complete shopping journey while maintaining clear separation between customer and administrator responsibilities.

The Cat Cafe project represents an end-to-end Flutter application rather than a collection of independent screens, with the different features connected together into one complete system.
