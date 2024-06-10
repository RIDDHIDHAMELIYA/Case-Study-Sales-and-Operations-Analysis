# Case Study Sales and Operations Analysis
![image](https://user-images.githubusercontent.com/120476961/229263876-bd47c7d7-260b-4bf3-9d45-16b8bd648ec0.png)

## 💼 Business Case and Requirement

You are a Data Analyst working for an e-commerce company named X. You are tasked with preparing a presentation to present an overview of the company's business and operations to date for Sales and Operations Managers. 

### The presentation should include at a minimum the following information: 
- Business overview. 
- Customer satisfaction.  
- 2 to 3 areas of recommendation (areas) where the company can improve.

### Some additional information for the case study:
- Since there is only data up to 2018, we will assume that it is currently September 2018 (data after September 2018 you can ignore).
- The company is based in the US, but incorporated in Brazil (that's why some information is written in Portuguese).
---

## 📂 Datasets

### 📎 Orders dataset

Provide information about orders
- order_id: unique ID of the order
- customer_id: unique ID of the customer
- order_status: order status
- order_purchase_timestamp: time when the order was ordered
- order_approved_at: time the order is approved
- order_delivered_carrier_date: the time the item was delivered to the carrier
- order_delivered_customer_date: the time the item was delivered to the customer
- order_estimated_delivery_date: the estimated time the order will be delivered to the customer

### 📎 Order items dataset  
Provide information about each item in the order and shipping costs
- order_id: unique ID of the order
- order_item_id: ID of the item in the order (item number 1 has ID 1, item 2 has ID 2, etc. Based on this we also know how many items each order has)
- product_id: unique ID of the product in the order
- seller_id: unique ID of the seller
- price: the price of the item
- freight_value: shipping fee

### 📎 Order payments dataset
Provide information of order payments.
*Note that we need to combine all values of each order to have total values.*
- order_id: unique ID of order
- payment_sequential: sequence order
- payment_type: payment type
- payment_installments: full payment (payment_installments = 1) or installment (payment_installments > 1,total payment is splited to many payments .
- payment_value: payment value (payment_value - equal total payments of all times payment installments)

### 📎 Product dataset 
Provide product information
- product_id: unique ID of product
- product_category_name: category product name 
- product_name_lenght: number of product name letters
- product_description_lenght: number of product description letters
- product_photos_qty: number of product photo
- product_weight_g: weight of product  (g)
- product_length_cm: length of product (cm)
- product_height_cm: height of product (cm)
- product_width_cm: width/deep of product (cm)

### 📎 Order reviews dataset 
Provide review details of each order
- review_id: unique ID of revie
- order_id: unique ID of order
- review_score: Review Score
- review_comment_title: Comment title
- review_comment_message: detail of review
- review_creation_date: Created date of review
- review_answer_timestamp: timestamp of review answers

### 📎 Customers dataset
Provide Customer Information 
- customer_id: customer unique ID ( used to link with customer_id of orders_dataset table.
- customer_unique_id: unique ID of customer in system of customer information management. 
- customer_zip_code_prefix: zip code of customer
- customer_city: City name of customer 
- customer_state: State name of customer
  
### 📎 product_category_name_translation
Provide product category name translation
- product_category_name 
- product_category_name_english

## A. Data Exploration and Cleaning by Google Big query
>**1.[Sales Analysis Query](https://github.com/RIDDHIDHAMELIYA/Case-Study-Sales-and-Operations-Analysis/blob/main/Sales_Query.sql)**
>**2.[Operations Analysis Query](https://github.com/RIDDHIDHAMELIYA/Case-Study-Sales-and-Operations-Analysis/blob/main/Operations_Query.sql)**

## B. [Analysis](https://github.com/RIDDHIDHAMELIYA/Case-Study-Sales-and-Operations-Analysis/blob/main/Sales_and_Operations_Analysis.pdf)

## C. [Looker Dashboard Link](https://lookerstudio.google.com/reporting/9d1ec006-00ac-40ba-9686-4af9577e4bfb)

