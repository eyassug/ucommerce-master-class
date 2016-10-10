using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using MyUCommerceApp.Website.Models;
using UCommerce.Api;
using UCommerce.Extensions;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassProductController : Umbraco.Web.Mvc.RenderMvcController
    {
		public ActionResult Index()
		{
			ProductViewModel productModel = new ProductViewModel();
			productModel = MapProduct(
				UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentProduct);
            return View("/views/product.cshtml", productModel);
		}

		private ProductViewModel MapProduct(UCommerce.EntitiesV2.Product currentProduct)
		{
			var model = new ProductViewModel();

			model.Sku = currentProduct.Sku;
			model.Name = currentProduct.DisplayName();
			model.LongDescription = currentProduct.LongDescription();

			model.PriceCalculation = 
				UCommerce.Api.CatalogLibrary.CalculatePrice(currentProduct);

			model.VariantSku = currentProduct.VariantSku;
			model.IsVariant = currentProduct.IsVariant;

			foreach (UCommerce.EntitiesV2.Product variant in currentProduct.Variants)
			{
				model.Variants.Add(MapProduct(variant));
			}
			return model;
		}


		[HttpPost]
		public ActionResult Index(AddToBasketViewModel model)
		{
			UCommerce.Api.TransactionLibrary.AddToBasket(1, model.Sku, model.VariantSku);
		
            return Index();
        }
    }
}