// lib/utils/invoice_html_builder.dart
import 'package:intl/intl.dart';
import 'package:veegify/model/previous_order.dart';

/// Build colorful Veegify invoice HTML (pista green, pure veg)
String buildInvoiceHtml(Order order) {
  print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df${order.deliveryCharge}");
    print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df${order.gstAmount}");

  print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df${order.gstOnDelivery}");

  print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df${order.totalPayable}");

  print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df${order.subTotal}");

  print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df${order.platformCharge}");
    print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df${order.packingCharges}");



  final rowsBuffer = StringBuffer();

  // Build rows using backend price (with a safe fallback)
  for (int i = 0; i < order.products.length; i++) {
    final item = order.products[i];

    // Safe unit price: prefer price if > 0, else basePrice, else 0
    final double unitPrice;
    if ((item.price ?? 0) > 0) {
      unitPrice = item.price!;
    } else if ((item.basePrice ?? 0) > 0) {
      unitPrice = item.basePrice!;
    } else {
      unitPrice = 0;
    }

    final int quantity = item.quantity ?? 0;
    final double lineTotal = unitPrice * quantity;

    // Plate label
    String plateLabel = '';
    if (item.isHalfPlate == true) plateLabel = 'Half Plate';
    if (item.isFullPlate == true) plateLabel = 'Full Plate';

    // Use product image if present, fallback placeholder block otherwise
    final imgTag = (item.image != null && item.image!.isNotEmpty)
        ? '<img src="${item.image}" class="item-img" />'
        : '<div class="item-img placeholder"></div>';

    rowsBuffer.writeln("""
      <tr class="item-row">
        <td class="cell index">${i + 1}</td>
        <td class="cell name">
          <div class="item-info">
            $imgTag
            <div class="item-text">
              <div class="item-name">${item.name ?? ''}</div>
              ${plateLabel.isNotEmpty ? '<div class="item-meta">$plateLabel</div>' : ''}
            </div>
          </div>
        </td>
        <td class="cell qty">$quantity</td>
        <td class="cell price">₹${unitPrice.toStringAsFixed(2)}</td>
        <td class="cell total">₹${lineTotal.toStringAsFixed(2)}</td>
      </tr>
    """);
  }

  final createdAt = (order.createdAt ?? DateTime.now()).toLocal();
  final formattedDate =
      DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

  // ====== NUMERIC VALUES WITH NULL HANDLING ======

  // Base totals (fallback to 0, but always show these lines)
  final double itemsTotal = (order.subTotal ?? 0).toDouble();
  final double grandTotal = (order.totalPayable ?? 0).toDouble();

  // Optional charges: if null -> line is not shown
  final double? gst = order.gstAmount;
  final double? gstOnDelivery = order.gstOnDelivery;
      final double? amountSavedOnOrder = order.amountSavedOnOrder;

  final double? packingCharges = order.packingCharges;
  final double? platformCharge = order.platformCharge;
  final double? deliveryCharge = order.deliveryCharge;

  // Coupon: null -> 0, line shown only when > 0
  final double coupon = (order.couponDiscount ?? 0).toDouble();

  final String itemsTotalFormatted = itemsTotal.toStringAsFixed(2);
  final String grandTotalFormatted = grandTotal.toStringAsFixed(2);

  final String gstLine = gst != null
      ? '''
          <div class="summary-line">
            <span class="summary-label">GST (Items)</span>
            <span class="summary-value">₹${gst.toStringAsFixed(2)}</span>
          </div>
        '''
      : '';

  final String gstDeliveryLine = gstOnDelivery != null
      ? '''
          <div class="summary-line">
            <span class="summary-label">GST on Delivery</span>
            <span class="summary-value">₹${gstOnDelivery.toStringAsFixed(2)}</span>
          </div>
        '''
      : '';

  final String packingLine = packingCharges != null
      ? '''
          <div class="summary-line">
            <span class="summary-label">Packing Charges</span>
            <span class="summary-value">₹${packingCharges.toStringAsFixed(2)}</span>
          </div>
        '''
      : '';

  final String platformLine = platformCharge != null
      ? '''
          <div class="summary-line">
            <span class="summary-label">Platform Charge</span>
            <span class="summary-value">₹${platformCharge.toStringAsFixed(2)}</span>
          </div>
        '''
      : '';

  final String deliveryLine = deliveryCharge != null
      ? '''
          <div class="summary-line">
            <span class="summary-label">Delivery Charge</span>
            <span class="summary-value">₹${deliveryCharge.toStringAsFixed(2)}</span>
          </div>
        '''
      : '';

  final String couponBlock = coupon > 0
      ? '''
          <div class="summary-line muted">
            <span class="summary-label">Coupon Discount</span>
            <span class="summary-value negative">-₹${coupon.toStringAsFixed(2)}</span>
          </div>
        '''
      : '';

                    final String amountSavedOnOrderr = amountSavedOnOrder != null
      ? '''
          <div class="summary-line">
            <span class="summary-label">Your Saving</span>
            <span class="summary-value">₹${amountSavedOnOrder.toStringAsFixed(2)}</span>
          </div>
        '''
      : '';

  // Delivery address safe join
  final da = order.deliveryAddress;
  final deliveryAddress = [
    da?.street,
    da?.city,
  ].where((e) => e != null && e!.trim().isNotEmpty).join(', ');

  final transactionLine =
      order.transactionId != null && order.transactionId!.trim().isNotEmpty
          ? '<div class="info-muted">Txn ID: ${order.transactionId}</div>'
          : '';

  return """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Invoice ${order.id ?? ''}</title>
  <style>
    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      padding: 24px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
      background: #f5f7f5;
      color: #223322;
    }

    .invoice-wrapper {
      max-width: 800px;
      margin: 0 auto;
      background: #ffffff;
      border-radius: 16px;
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.06);
      overflow: hidden;
      border: 1px solid #e1f2e1;
    }

    /* HEADER */

    .invoice-header {
      background: linear-gradient(135deg, #7cb342, #9ccc65);
      padding: 20px 24px;
      color: #ffffff;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .brand-logo {
      width: 55px;
      height: 55px;
      border-radius: 50%;
      overflow: hidden;
      border: 3px solid #A5D6A7; /* pista green border */
      display: flex;
      align-items: center;
      justify-content: center;
      background: #E8F5E9;
    }

    .brand-logo-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .brand-text {
      display: flex;
      flex-direction: column;
    }

    .brand-title {
      font-size: 18px;
      font-weight: 700;
      letter-spacing: 0.6px;
    }

    .brand-subtitle {
      font-size: 11px;
      opacity: 0.95;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .veg-icon {
      width: 12px;
      height: 12px;
      border-radius: 3px;
      border: 1.5px solid #1b5e20;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #e8f5e9;
    }

    .veg-icon-inner {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: #1b5e20;
    }

    .invoice-meta {
      text-align: right;
      font-size: 12px;
    }

    .invoice-id {
      font-weight: 600;
      font-size: 14px;
    }

    .status-chip {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      margin-top: 8px;
      padding: 4px 10px;
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.16);
      font-size: 11px;
      font-weight: 500;
    }

    .status-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: #c8e6c9;
    }

    .invoice-body {
      padding: 20px 24px 24px;
    }

    /* SECTION TITLES */

    .section-title {
      font-size: 13px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #7f8d7f;
      margin-bottom: 6px;
    }

    .info-row {
      display: flex;
      justify-content: space-between;
      gap: 16px;
      margin-bottom: 16px;
      flex-wrap: wrap;
    }

    .info-card {
      flex: 1;
      min-width: 220px;
      padding: 12px 14px;
      border-radius: 12px;
      background: #f7fbf7;
      border: 1px solid #e1f2e1;
    }

    .info-label {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #9e9e9e;
      margin-bottom: 4px;
    }

    .info-value {
      font-size: 13px;
      font-weight: 500;
      color: #334433;
    }

    .info-muted {
      font-size: 12px;
      color: #6b7b6b;
      margin-top: 2px;
      white-space: pre-line;
    }

    .items-section-title {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin: 12px 0 8px;
    }

    .badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 3px 10px;
      border-radius: 999px;
      font-size: 11px;
      background: rgba(124, 179, 66, 0.12);
      color: #33691e;
      font-weight: 500;
    }

    .badge-dot {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: #33691e;
    }

    /* TABLE */

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 4px;
      border-radius: 12px;
      overflow: hidden;
    }

    thead {
      background: #f1f8e9;
    }

    th {
      padding: 10px 8px;
      font-size: 12px;
      font-weight: 600;
      color: #558b2f;
      text-align: left;
      border-bottom: 1px solid #dcedc8;
      white-space: nowrap;
    }

    th:last-child,
    td:last-child {
      text-align: right;
    }

    th:nth-child(3),
    td:nth-child(3),
    th:nth-child(4),
    td:nth-child(4) {
      text-align: center;
    }

    .item-row:nth-child(odd) {
      background: #fafdf7;
    }

    .item-row:nth-child(even) {
      background: #ffffff;
    }

    .cell {
      padding: 9px 8px;
      font-size: 12px;
      border-bottom: 1px solid #eef3ea;
    }

    .cell.index {
      color: #9e9e9e;
      width: 32px;
    }

    .cell.name {
      font-weight: 500;
      color: #374837;
    }

    .cell.qty {
      font-weight: 500;
    }

    .cell.price,
    .cell.total {
      font-feature-settings: "tnum" 1, "lnum" 1;
    }

    .item-info {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .item-img {
      width: 32px;
      height: 32px;
      border-radius: 8px;
      object-fit: cover;
      border: 1px solid #dce8dc;
    }

    .item-img.placeholder {
      background: #e8f5e9;
    }

    .item-text {
      display: flex;
      flex-direction: column;
    }

    .item-name {
      font-size: 12px;
      font-weight: 600;
    }

    .item-meta {
      font-size: 10px;
      color: #689f38;
    }

    /* SUMMARY */

    .summary-row {
      margin-top: 18px;
      display: flex;
      justify-content: flex-end;
    }

    .summary-card {
      width: 280px;
      padding: 14px 16px;
      border-radius: 14px;
      background: #f7fbf7;
      border: 1px solid #dcedc8;
    }

    .summary-line {
      display: flex;
      justify-content: space-between;
      font-size: 12px;
      margin-bottom: 6px;
      color: #566656;
    }

    .summary-line.muted {
      color: #8a9a8a;
    }

    .summary-line.total {
      margin-top: 6px;
      padding-top: 8px;
      border-top: 1px dashed rgba(85, 139, 47, 0.5);
      font-weight: 700;
      font-size: 13px;
      color: #2e7d32;
    }

    .summary-label {
      font-weight: 500;
    }

    .summary-value {
      font-feature-settings: "tnum" 1, "lnum" 1;
    }

    .summary-value.negative {
      color: #c62828;
    }

    /* FOOTER */

    .footer-note {
      margin-top: 24px;
      padding-top: 12px;
      border-top: 1px dashed #e0e0e0;
      font-size: 11px;
      color: #8a9a8a;
      text-align: center;
    }

    .footer-brand {
      color: #2e7d32;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <div class="invoice-wrapper">
    <div class="invoice-header">
      <div class="brand">
        <div class="brand-logo">
          <img 
            src="https://vegiffyy.com/static/media/veggifylogo.3fc4c1893871f095e27e.jpeg" 
            alt="Veegify Logo" 
            class="brand-logo-img"
          />
        </div>
        <div class="brand-text">
          <div class="brand-title">Vegiffyy</div>
          <div class="brand-subtitle">
            <span>Pure Veg Delivery</span>
            <span class="veg-icon">
              <span class="veg-icon-inner"></span>
            </span>
          </div>
        </div>
      </div>
      <div class="invoice-meta">
        <div class="invoice-id">Invoice #${order.id ?? ''}</div>
        <div style="margin-top: 4px;">
          <span style="opacity: 0.85;">Date:</span>
          <span style="font-weight: 500;">
            $formattedDate
          </span>
        </div>
        <div class="status-chip">
          <span class="status-dot"></span>
          <span>Delivered</span>
        </div>
      </div>
    </div>

    <div class="invoice-body">
      <div class="section-title">Order & Customer</div>
      <div class="info-row">
        <div class="info-card">
          <div class="info-label">Order Details</div>
          <div class="info-value">Order ID: ${order.id ?? ''}</div>
          <div class="info-muted">
            Placed on: $formattedDate
          </div>
          <div class="info-muted">
            Payment: ${order.paymentMethod ?? ''} • ${order.paymentStatus ?? ''}
          </div>
          $transactionLine
        </div>

        <div class="info-card">
          <div class="info-label">Deliver To</div>
          <div class="info-value">$deliveryAddress</div>
          <div class="info-muted">
            Items: ${order.totalItems ?? order.products.length}
          </div>
        </div>
      </div>

      <div class="section-title">Restaurant</div>
      <div class="info-row" style="margin-bottom: 12px;">
        <div class="info-card">
          <div class="info-label">Restaurant</div>
          <div class="info-value">${order.restaurant.restaurantName ?? ''}</div>
          <div class="info-muted">
            ${order.restaurant.locationName ?? ''}
          </div>
        </div>
      </div>

      <div class="items-section-title">
        <div class="section-title" style="margin-bottom: 0;">Items</div>
        <div class="badge">
          <span class="badge-dot"></span>
          ${order.products.length} item${order.products.length == 1 ? '' : 's'}
        </div>
      </div>

      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Item</th>
            <th>Qty</th>
            <th>Price</th>
            <th>Item Total</th>
          </tr>
        </thead>
        <tbody>
          ${rowsBuffer.toString()}
        </tbody>
      </table>

      <div class="summary-row">
        <div class="summary-card">
          <div class="summary-line">
            <span class="summary-label">Items Total</span>
            <span class="summary-value">₹$itemsTotalFormatted</span>
          </div>
          $gstLine
          $gstDeliveryLine
          $packingLine
          $platformLine
          $deliveryLine
          $couponBlock
                              $amountSavedOnOrderr

          <div class="summary-line total">
            <span class="summary-label">Grand Total</span>
            <span class="summary-value">₹$grandTotalFormatted</span>
          </div>
        </div>
      </div>

      <div class="footer-note">
        Thank you for ordering with <span class="footer-brand">Vegiffyy</span>.<br/>
        For help with this order, contact support with your invoice ID.
      </div>
    </div>
  </div>
</body>
</html>
  """;
}
