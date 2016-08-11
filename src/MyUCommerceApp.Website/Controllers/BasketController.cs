using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.MasterClass.Website.Models;

namespace UCommerce.MasterClass.Website.Controllers
{
	public class BasketController : System.Web.Mvc.Controller
	{
		public ActionResult Index()
		{
			var basketModel = new PurchaseOrderViewModel();

			return View("/Views/Basket.cshtml", basketModel);
		}

		[HttpPost]
		public ActionResult Index(PurchaseOrderViewModel model)
		{
			return Index();
		}
	}
}