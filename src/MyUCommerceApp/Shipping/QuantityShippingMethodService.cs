using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Transactions.Shipping;

namespace MyUCommerceApp.BusinessLogic.Shipping
{
	public class QuantityShippingMethodService : UCommerce.Transactions.Shipping.IShippingMethodService
	{
		public Money CalculateShippingPrice(Shipment shipment)
		{
			int totalQuantity = shipment.OrderLines.Sum(x => x.Quantity);

			return new Money(totalQuantity * 10, shipment.PurchaseOrder.BillingCurrency);
		}

		public bool ValidateForShipping(Shipment shipment)
		{
			return true;
		}
	}
}
