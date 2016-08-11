using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class ShippingController : Umbraco.Web.Mvc.RenderMvcController
    {
		public ActionResult Index()
		{
			var shippingViewModel = new ShippingViewModel();

			return View("/Views/Shipping.cshtml", shippingViewModel);
		}

		[HttpPost]
		public ActionResult Index(ShippingViewModel shipping)
		{
			return Redirect("/store/checkout/payment");
		}
	}
}