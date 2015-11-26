using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce;
using UCommerce.EntitiesV2;
using UCommerce.Security;
using UCommerce.Transactions.Shipping;

namespace MyUCommerceApp.BusinessLogic.Shipping
{
	public class QuantityShippingMethodService : IShippingMethodService
	{
		private readonly int _multiplier;
		private readonly int _upperPriceLimit;
		
		public QuantityShippingMethodService(int multiplier, int upperPriceLimit)
		{
			_multiplier = multiplier;
			_upperPriceLimit = upperPriceLimit;
		}

		public Money CalculateShippingPrice(Shipment shipment)
		{
			ValidateForShipping(shipment);

			var quantity = shipment.OrderLines.Sum(orderLine => orderLine.Quantity);

			var shippingPrice = quantity*_multiplier;

			if (shippingPrice > _upperPriceLimit)
				return new Money(_upperPriceLimit,shipment.PurchaseOrder.BillingCurrency);

			return new Money(shippingPrice,shipment.PurchaseOrder.BillingCurrency);
		}

		public bool ValidateForShipping(Shipment shipment)
		{
			if (shipment.ShipmentAddress == null)
				return false;

			if (shipment.ShipmentAddress.Country == null)
				return false;

			if (shipment.ShippingMethod.EligibleCountries.Contains(shipment.ShipmentAddress.Country))
			{
				return true;
			}

			throw new InvalidOperationException(
				string.Format("Shipment for order {0} invalid. Used country: {1} on {2}", 
				shipment.PurchaseOrder.OrderGuid, 
				shipment.ShipmentAddress.Country, 
				shipment.ShippingMethod.Name));
		}
	}
}
