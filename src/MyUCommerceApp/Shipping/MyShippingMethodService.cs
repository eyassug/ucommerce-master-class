using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Transactions.Shipping;

namespace MyUCommerceApp.Shipping
{
	public class MyShippingMethodService : IShippingMethodService
	{
		public Money CalculateShippingPrice(Shipment shipment)
		{
			int totalQty = shipment.OrderLines.Sum(x => x.Quantity);

			return new Money(totalQty * 10, shipment.PurchaseOrder.BillingCurrency);
		}

		public bool ValidateForShipping(Shipment shipment)
		{
			if (shipment.ShipmentAddress != null
				&& shipment.ShipmentAddress.Country != null)
				return true;

			return shipment.ShippingMethod.EligibleCountries.Contains(
				shipment.ShipmentAddress.Country);
		}
	}
}