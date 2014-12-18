using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Transactions.Shipping;

namespace MyUCommerceApp.Shipping
{
	public class QuantityShippingMethodService : IShippingMethodService
	{
		public QuantityShippingMethodService()
		{
			
		}
		public Money CalculateShippingPrice(Shipment shipment)
		{
			int totalQuantity = shipment.OrderLines.Sum(x => x.Quantity);

			return new Money(
				totalQuantity * 10 , 
				shipment.PurchaseOrder.BillingCurrency);
		}

		public bool ValidateForShipping(Shipment shipment)
		{
			if (shipment.ShipmentAddress == null)
				return false;

			if (shipment.ShipmentAddress.Country == null)
				return false;

			return 
			shipment //verify that the shipment country is within the list 
			//of possible countries for our method.
				.ShippingMethod
				.EligibleCountries
				.Contains(shipment.ShipmentAddress.Country);

		}
	}
}
