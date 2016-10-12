using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce.EntitiesV2;
using UCommerce.Api;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassShippingController : Umbraco.Web.Mvc.RenderMvcController
    {
        public ActionResult Index()
        {
            var shippingModel = new ShippingViewModel();

	        var shippingInformation = TransactionLibrary.GetShippingInformation();

	        ICollection<ShippingMethod> availableShippingMethods =
		        UCommerce.Api.TransactionLibrary.GetShippingMethods(shippingInformation.Country);

	        ShippingMethod selectedShippingMethod = TransactionLibrary.GetShippingMethod();
	        int selectedShippingMethodId = -1;
	        if (selectedShippingMethod != null)
	        {
		        selectedShippingMethodId = selectedShippingMethod.ShippingMethodId;
	        }


	        foreach (var availableShippingMethod in availableShippingMethods)
	        {
				shippingModel.AvailableShippingMethods.Add(new SelectListItem()
				{
					Selected = selectedShippingMethodId == availableShippingMethod.ShippingMethodId,
					Text = availableShippingMethod.Name,
					Value = availableShippingMethod.ShippingMethodId.ToString()
				});
	        }

            return View("/Views/Shipping.cshtml", shippingModel);
        }

        [HttpPost]
        public ActionResult Index(ShippingViewModel shipping)
        {
			TransactionLibrary.CreateShipment(
				shippingMethodId: shipping.SelectedShippingMethodId,
				addressName: null,
				overwriteExisting: true);

			TransactionLibrary.ExecuteBasketPipeline();

            return Redirect("/payment");
		}
	}
}