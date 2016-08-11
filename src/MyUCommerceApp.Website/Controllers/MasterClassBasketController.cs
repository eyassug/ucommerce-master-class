﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassBasketController : Umbraco.Web.Mvc.RenderMvcController
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