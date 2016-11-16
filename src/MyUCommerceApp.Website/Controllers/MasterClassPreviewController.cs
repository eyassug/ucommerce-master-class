using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassPreviewController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            PurchaseOrderViewModel model = MapOrder();

            model.BillingAddress = MapOrderAddress(TransactionLibrary.GetBillingInformation());
            model.ShippingAddress = MapOrderAddress(TransactionLibrary.GetShippingInformation());

	        var basket = UCommerce.Api.TransactionLibrary.GetBasket(false).PurchaseOrder;
	        var billingCurrency = basket.BillingCurrency;

	        foreach (UCommerce.EntitiesV2.OrderLine orderLine in basket.OrderLines)
	        {
		        var orderLineViewModel = new OrderlineViewModel();

		        orderLineViewModel.Sku = orderLine.Sku;
		        orderLineViewModel.VariantSku = orderLine.VariantSku;
		        orderLineViewModel.ProductName = orderLine.ProductName;
		        orderLineViewModel.Quantity = orderLine.Quantity;
				orderLineViewModel.Total = new Money(orderLine.Total.GetValueOrDefault(), billingCurrency).ToString();

				model.OrderLines.Add(orderLineViewModel);
	        }

	        model.SubTotal = new Money(basket.SubTotal.GetValueOrDefault(), billingCurrency).ToString();
	        model.TaxTotal = new Money(basket.TaxTotal.GetValueOrDefault(), billingCurrency).ToString();
	        model.DiscountTotal = new Money(basket.DiscountTotal.GetValueOrDefault(), billingCurrency).ToString();

	        model.ShippingTotal = GetMoneyFormat(basket.ShippingTotal, billingCurrency);
	        model.PaymentTotal = GetMoneyFormat(basket.PaymentTotal, billingCurrency);
	        model.OrderTotal = GetMoneyFormat(basket.OrderTotal, billingCurrency);

            return View("/Views/mc/preview.cshtml", model);
        }

		private string GetMoneyFormat(decimal? amount, Currency currency)
		{
			return new Money(amount.GetValueOrDefault(), currency).ToString();
		}

		private AddressViewModel MapOrderAddress(OrderAddress orderAddress)
        {
            var addressDetails = new AddressViewModel();

            addressDetails.FirstName = orderAddress.FirstName;
            addressDetails.LastName = orderAddress.LastName;
            addressDetails.EmailAddress = orderAddress.EmailAddress;
            addressDetails.PhoneNumber = orderAddress.PhoneNumber;
            addressDetails.MobilePhoneNumber = orderAddress.MobilePhoneNumber;
            addressDetails.Line1 = orderAddress.Line1;
            addressDetails.Line2 = orderAddress.Line2;
            addressDetails.PostalCode = orderAddress.PostalCode;
            addressDetails.City = orderAddress.City;
            addressDetails.State = orderAddress.State;
            addressDetails.Attention = orderAddress.Attention;
            addressDetails.CompanyName = orderAddress.CompanyName;
            addressDetails.CountryId = orderAddress.Country != null ? orderAddress.Country.CountryId : -1;

            return addressDetails;
        }

        private PurchaseOrderViewModel MapOrder()
        {
            var basketModel = new PurchaseOrderViewModel();

            return basketModel;
        }

        [HttpPost]
        public ActionResult Index(bool checkout)
        {
			UCommerce.Api.TransactionLibrary.RequestPayments();

            return View("/Views/mc/Complete.cshtml");
        }
    }
}