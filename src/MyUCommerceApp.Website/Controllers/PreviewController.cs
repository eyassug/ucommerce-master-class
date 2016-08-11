using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce.MasterClass.Website.Models;

namespace UCommerce.MasterClass.Website.Controllers
{
	public class PreviewController : System.Web.Mvc.Controller
	{
		public ActionResult Index()
		{
			PurchaseOrderViewModel model = MapOrder();
			
			model.BillingAddress = MapOrderAddress(TransactionLibrary.GetBillingInformation());
			model.ShippingAddress = MapOrderAddress(TransactionLibrary.GetShippingInformation());

			return View("/Views/preview.cshtml", model);
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
		public ActionResult Post()
		{
			return View("/Views/Complete.cshtml");
		}
	}
}