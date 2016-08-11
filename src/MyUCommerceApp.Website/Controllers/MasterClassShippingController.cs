﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassShippingController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            var shipping = new ShippingViewModel();
            shipping.AvailableShippingMethods = new List<SelectListItem>();

            var shippingInformation = UCommerce.Api.TransactionLibrary.GetShippingInformation();

            var availableShippingMethods = TransactionLibrary.GetShippingMethods(shippingInformation.Country);

            var selectedShippingMethod = TransactionLibrary.GetShippingMethod();

            int selectedShippingMethodId = -1;
            if (selectedShippingMethod != null)
            {
                selectedShippingMethodId = selectedShippingMethod.ShippingMethodId;
            }

            foreach (var availableShippingMethod in availableShippingMethods)
            {
                shipping.AvailableShippingMethods.Add(new SelectListItem()
                {
                    Selected = selectedShippingMethodId == availableShippingMethod.ShippingMethodId,
                    Text = availableShippingMethod.Name,
                    Value = availableShippingMethod.ShippingMethodId.ToString()
                });
            }

            return View("/Views/Shipping.cshtml", shipping);
        }

        [HttpPost]
        public ActionResult Index(ShippingViewModel shipping)
        {
            TransactionLibrary.CreateShipment(shipping.SelectedShippingMethodId, overwriteExisting: true);
            TransactionLibrary.ExecuteBasketPipeline();

            return Redirect("/payment");
		}
	}
}