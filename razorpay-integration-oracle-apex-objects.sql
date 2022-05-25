------------------------------------------------------------------------
-- Project: Razorpay Integration with Oracle APEX
-- Author: Karkuvelraja Thangamariappan
------------------------------------------------------------------------

DROP TABLE fmgn_rzp_orders;
DROP SEQUENCE fmgn_rzp_orders_s;
/

------------------------------------------------------------------------
-- TABLE: F M G N _ R Z P _ O R D E R S
------------------------------------------------------------------------

CREATE TABLE fmgn_rzp_orders
  (
    rzp_id                  NUMBER PRIMARY KEY,
    order_id                VARCHAR2(240),
    amount                  NUMBER,
    currency                VARCHAR2(240),
    status                  VARCHAR2(240),
    error_code              VARCHAR2(240),
    error_description       VARCHAR2(240),
    receipt_number          VARCHAR2(240),
    created_by              VARCHAR2(240),
    created_on              TIMESTAMP,
    updated_by              VARCHAR2(240),
    updated_on              TIMESTAMP
  );
/

------------------------------------------------------------------------
-- SEQUENCE: F M G N _ R Z P _ O R D E R S _ S
------------------------------------------------------------------------

CREATE SEQUENCE fmgn_rzp_orders_s START WITH 1 INCREMENT BY 1;
/

------------------------------------------------------------------------
-- TRIGGER: F M G N _ R Z P _ O R D E R S _ B I U
------------------------------------------------------------------------

CREATE OR REPLACE 
TRIGGER fmgn_rzp_orders_biu 
   BEFORE INSERT OR UPDATE ON fmgn_rzp_orders
   FOR EACH ROW
BEGIN
    IF (inserting AND :NEW.rzp_id IS NULL) THEN
       SELECT fmgn_rzp_orders_s.nextval INTO :NEW.rzp_id FROM dual; 
       
       :NEW.created_on := LOCALTIMESTAMP;
       :NEW.created_by := nvl(wwv_flow.g_user,USER);		
    END IF;
	
   IF updating THEN
       :NEW.updated_on := LOCALTIMESTAMP;
       :NEW.updated_by := nvl(wwv_flow.g_user,USER);
   END IF;
END fmgn_rzp_orders_biu;
/

ALTER TRIGGER fmgn_rzp_orders_biu ENABLE;
/

DROP TABLE fmgn_rzpay_payment_response;
DROP SEQUENCE fmgn_rzpay_payment_response_s;
/

------------------------------------------------------------------------
-- TABLE: F M G N _ R Z P A Y _ P A Y M E N T _ R E S P O N S E
------------------------------------------------------------------------

CREATE TABLE fmgn_rzpay_payment_response
  (
    response_id NUMBER,
    order_id    VARCHAR2(240),
    payment_id  VARCHAR2(240),
    webhook_response CLOB,
    created_by VARCHAR2(240),
    created_on TIMESTAMP,
    updated_by VARCHAR2(240),
    updated_on TIMESTAMP
  );
/

------------------------------------------------------------------------
-- SEQUENCE: F M G N _ R Z P A Y _ P A Y M E N T _ R E S P O N S E _ S
------------------------------------------------------------------------

CREATE SEQUENCE fmgn_rzpay_payment_response_s START WITH 1 INCREMENT BY 1;
/

------------------------------------------------------------------------
-- TRIGGER: F M G N _ R Z P A Y _ P A Y M E N T _ R E S P O N S E _ B I U
------------------------------------------------------------------------

CREATE OR REPLACE 
TRIGGER fmgn_rzpay_payment_response_biu 
   BEFORE INSERT OR UPDATE ON fmgn_rzpay_payment_response
   FOR EACH ROW
BEGIN
    IF (inserting AND :NEW.response_id IS NULL) THEN
       SELECT fmgn_rzpay_payment_response_s.nextval INTO :NEW.response_id FROM dual; 
       
       :NEW.created_on := LOCALTIMESTAMP;
       :NEW.created_by := nvl(wwv_flow.g_user,USER);		
    END IF;
	
   IF updating THEN
       :NEW.updated_on := LOCALTIMESTAMP;
       :NEW.updated_by := nvl(wwv_flow.g_user,USER);
   END IF;
END fmgn_rzpay_payment_response_biu;
/

ALTER TRIGGER fmgn_rzpay_payment_response_biu ENABLE;
/

DROP TABLE fmgn_rzpay_payment_activities;
DROP SEQUENCE fmgn_rzpay_payment_activities_s;
/

------------------------------------------------------------------------
-- TABLE: F M G N _ R Z P A Y _ P A Y M E N T _ A C T I V I T I E S
------------------------------------------------------------------------

CREATE TABLE fmgn_rzpay_payment_activities
  (
    activity_id               NUMBER,
    order_id                  VARCHAR2(240),
    payment_id                VARCHAR2(240),
    payment_status            VARCHAR2(240),
    event                     VARCHAR2(240),
    entity                    VARCHAR2(240),
    payment_amount            NUMBER,
    payment_currency          VARCHAR2(240),
    payment_date              DATE,
    payment_error_code        VARCHAR2(240),
    payment_error_description VARCHAR2(240),
    order_status              VARCHAR2(240),
    created_by                VARCHAR2(240),
    created_on                TIMESTAMP,
    updated_by                VARCHAR2(240),
    updated_on                TIMESTAMP
  );
/

------------------------------------------------------------------------
-- SEQUENCE: F M G N _ R Z P A Y _ P A Y M E N T _ A C T I V I T I E S _ S
------------------------------------------------------------------------

CREATE SEQUENCE fmgn_rzpay_payment_activities_s START WITH 1 INCREMENT BY 1;
/

------------------------------------------------------------------------
-- SEQUENCE: F M G N _ R Z P A Y _ P A Y M E N T _ A C T I V I T I E S _ B I U
------------------------------------------------------------------------

CREATE OR REPLACE 
TRIGGER fmgn_rzpay_payment_activities_biu 
   BEFORE INSERT OR UPDATE ON fmgn_rzpay_payment_activities
   FOR EACH ROW
BEGIN
    IF (inserting AND :NEW.activity_id IS NULL) THEN
       SELECT fmgn_rzpay_payment_activities_s.nextval INTO :NEW.activity_id FROM dual; 
       
       :NEW.created_on := LOCALTIMESTAMP;
       :NEW.created_by := nvl(wwv_flow.g_user,USER);		
    END IF;
	
   IF updating THEN
       :NEW.updated_on := LOCALTIMESTAMP;
       :NEW.updated_by := nvl(wwv_flow.g_user,USER);
   END IF;
END fmgn_rzpay_payment_activities_biu;
/

ALTER TRIGGER fmgn_rzpay_payment_activities_biu ENABLE;
/

------------------------------------------------------------------------
-- PACKAGE: F M G N _ R Z P _ I N T E G R A T I O N
------------------------------------------------------------------------
CREATE OR REPLACE
PACKAGE fmgn_rzp_integration
AS
  PROCEDURE fmgn_create_rzpay_order(
      p_amount              IN  VARCHAR2,
      p_receipt_number      IN  VARCHAR2,
      x_rzpay_order_id      OUT VARCHAR2,
      x_rzpay_order_amount  OUT NUMBER,
      x_rzpay_order_status  OUT VARCHAR2,
      x_rxpay_error_code    OUT VARCHAR2,
      x_rzpay_error_msg     OUT VARCHAR2,
      x_rzpay_order_receipt OUT VARCHAR2);
      
  PROCEDURE fmgn_rzpay_webhook_response(
      p_webhook_response IN BLOB);
END fmgn_rzp_integration;
/

------------------------------------------------------------------------
-- PACKAGE BODY: F M G N _ R Z P _ I N T E G R A T I O N
------------------------------------------------------------------------

create or replace PACKAGE BODY fmgn_rzp_integration
AS
PROCEDURE fmgn_create_rzpay_order( 
    p_amount              IN  VARCHAR2, 
    p_receipt_number      IN  VARCHAR2, 
    x_rzpay_order_id      OUT VARCHAR2, 
    x_rzpay_order_amount  OUT NUMBER, 
    x_rzpay_order_status  OUT VARCHAR2, 
    x_rxpay_error_code    OUT VARCHAR2, 
    x_rzpay_error_msg     OUT VARCHAR2, 
    x_rzpay_order_receipt OUT VARCHAR2) 
IS 
  l_code              VARCHAR2(240); 
  l_response          CLOB; 
  l_json              apex_json.t_values; 
  l_rzpay_order_id    VARCHAR2(240); 
  l_rzpay_api_key     VARCHAR2(240) := '<<YOUR_RAZORPAY_KEY_API>>'; 
  l_rzpay_api_secret  VARCHAR2(240) := '<<YOUR_RAZORPAY_KEY_SECRET>>'; 
  l_order_currency    VARCHAR2(240) := 'INR'; 
BEGIN 
  apex_web_service.g_request_headers.DELETE; 
   
  apex_web_service.g_request_headers(apex_web_service.g_request_headers.count + 1).NAME := 'Content-Type'; 
  apex_web_service.g_request_headers(apex_web_service.g_request_headers.count).VALUE    := 'application/json'; 
   
  apex_json.initialize_clob_output(DBMS_LOB.CALL, true, 2); 
  apex_json.open_object(); 
  apex_json.WRITE('amount', p_amount); 
  apex_json.WRITE('currency', 'INR'); 
  apex_json.write('receipt', p_receipt_number); 
  apex_json.close_object;  
     
  l_response := apex_web_service.make_rest_request(p_url => 'https://api.razorpay.com/v1/orders',  
                                                   p_http_method => 'POST',  
                                                   p_username => l_rzpay_api_key, -- razorpay api key 
                                                   p_password => l_rzpay_api_secret, -- razorpay api secret available in dashboard 
                                                   p_body     => apex_json.get_clob_output 
                                                   ); 
						   
    if apex_web_service.g_status_code not between 200 and 299 then 
        raise_application_error(-20000, 'HTTP-'|| apex_web_service.g_status_code); 
    end if; 
     
  apex_json.parse(l_response); 
   
  x_rzpay_order_id       := apex_json.get_varchar2(p_path => 'id'); 
  x_rzpay_order_amount   := apex_json.get_number(p_path => 'amount'); 
  x_rzpay_order_status   := apex_json.get_varchar2(p_path => 'status'); 
  x_rzpay_order_receipt  := apex_json.get_varchar2(p_path => 'receipt'); 
   
  IF x_rzpay_order_id    IS NULL THEN 
    x_rzpay_order_status := 'Failed'; 
  END IF; 
   
  x_rxpay_error_code := apex_json.get_varchar2 (p_path => 'error.code',p0 => 1); 
  x_rzpay_error_msg := apex_json.get_varchar2 (p_path => 'error.description',p0 => 1); 
   
  INSERT 
    INTO fmgn_rzp_orders 
      ( 
        order_id, 
        amount, 
        currency, 
        status, 
	error_code, 
        error_description, 
        receipt_number 
      ) 
      VALUES 
      ( 
        x_rzpay_order_id, 
        x_rzpay_order_amount/100, 
        'INR', 
        x_rzpay_order_status, 
	x_rxpay_error_code, 
        x_rzpay_error_msg, 
        x_rzpay_order_receipt 
      );
COMMIT; 
exception 
WHEN others THEN 
  raise_application_error (-20001, sqlerrm) ; 
END fmgn_create_rzpay_order; 

PROCEDURE fmgn_rzpay_webhook_response(
    p_webhook_response IN BLOB)
AS
  l_clob CLOB;
  l_dest_offsset          INTEGER := 1;
  l_src_offsset           INTEGER := 1;
  l_lang_context          INTEGER := dbms_lob.default_lang_ctx;
  l_warning               INTEGER;
  l_razpay_order_id       VARCHAR2(100) := NULL;
  l_final_amount          NUMBER        := NULL;
BEGIN
  dbms_lob.createtemporary(l_clob, TRUE);
  -- convert binary body to clob
  dbms_lob.converttoclob ( dest_lob => l_clob , 
                           src_blob => p_webhook_response , 
                           amount => dbms_lob.lobmaxsize , 
                           dest_offset => l_dest_offsset , 
                           src_offset => l_src_offsset , 
                           blob_csid => dbms_lob.default_csid , 
                           lang_context => l_lang_context , 
                           warning => l_warning 
                         );
  
  apex_json.parse (l_clob);
  
  INSERT
  INTO fmgn_rzpay_payment_response
    (
      order_id,
      payment_id,
      webhook_response
    )
    VALUES
    (
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.order_id',p0 => 1) ,
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.id',p0 => 1) ,
      l_clob
    );
	
  l_razpay_order_id := apex_json.get_varchar2 (p_path =>'payload.payment.entity.order_id',p0 => 1);
  l_final_amount    := to_number(apex_json.get_varchar2 (p_path => 'payload.payment.entity.amount',p0 => 1));
  
  INSERT
  INTO fmgn_rzpay_payment_activities
    (
      order_id,
      payment_id,
      payment_status,
      event,
      entity,
      payment_amount,
      payment_currency,
      payment_date,
      payment_error_code,
      payment_error_description,
      order_status
    )
    VALUES
    (
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.order_id',p0 => 1) ,
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.ID',p0 => 1) ,
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.status',p0 => 1) ,
      apex_json.get_varchar2 (p_path => 'event',p0 => 1) ,
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.entity',p0 => 1) ,
      l_final_amount/100,
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.currency',p0 => 1) ,
      SYSDATE ,
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.error_code',p0 => 1) ,
      apex_json.get_varchar2 (p_path => 'payload.payment.entity.error_description',p0 => 1) ,
      apex_json.get_varchar2 (p_path => 'payload.order.entity.status',p0 => 1)
    );
    
  IF (apex_json.get_varchar2 (p_path => 'event',p0 => 1)) = 'payment.failed' THEN
    UPDATE fmgn_rzpay_payment_activities
    SET order_status      = 'failed'
    WHERE order_id = l_razpay_order_id;
  END IF;
  COMMIT;
END fmgn_rzpay_webhook_response;
END fmgn_rzp_integration;
/
