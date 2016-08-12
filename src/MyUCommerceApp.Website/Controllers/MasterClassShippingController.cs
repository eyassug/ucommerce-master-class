using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassShippingController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            var shippingModel = new ShippingViewModel();

            return View("/Views/Shipping.cshtml", shippingModel);
        }

        [HttpPost]
        public ActionResult Index(ShippingViewModel shipping)
        {
            return Redirect("/payment");
		}
	}
}