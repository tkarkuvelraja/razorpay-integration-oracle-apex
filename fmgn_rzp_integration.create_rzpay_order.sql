DECLARE
  p_amount              NUMBER;
  p_receipt_number      VARCHAR2(200);
  x_rzpay_order_id      VARCHAR2(200);
  x_rzpay_order_amount  NUMBER;
  x_rzpay_order_status  VARCHAR2(200);
  x_rzpay_error_code    VARCHAR2(200);
  x_rzpay_error_msg     VARCHAR2(200);
  x_rzpay_order_receipt VARCHAR2(200);
BEGIN

  SELECT COUNT(rzp_id) 
    INTO l_orders 
    FROM fmgn_rzp_orders;

  p_amount         := :P19_AMOUNT; -- Replace this page item with your page item
  p_receipt_number := 'receipt#'||l_orders;
  
  fmgn_rzp_integration.create_rzpay_order ( p_amount => p_amount, 
					    p_receipt_number => p_receipt_number, 
					    x_rzpay_order_id => x_rzpay_order_id, 
					    x_rzpay_order_amount => x_rzpay_order_amount, 
					    x_rzpay_order_status => x_rzpay_order_status, 
					    x_rxpay_error_code => x_rzpay_error_code,
					    x_rzpay_error_msg => x_rzpay_error_msg, 
					    x_rzpay_order_receipt => x_rzpay_order_receipt
					  );
  
  dbms_output.put_line('X_RZPAY_ORDER_ID = ' || x_rzpay_order_id);
  dbms_output.put_line('X_RZPAY_ORDER_AMOUNT = ' || x_rzpay_order_amount);
  dbms_output.put_line('X_RZPAY_ORDER_STATUS = ' || x_rzpay_order_status);
  dbms_output.put_line('X_RZPAY_ERROR_MSG = ' || x_rzpay_error_msg);
  dbms_output.put_line('X_RZPAY_ORDER_RECEIPT = ' || x_rzpay_order_receipt);
END;
/
