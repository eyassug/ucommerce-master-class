using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using MyUCommerceApp.Website.Models;
using UCommerce.EntitiesV2;
using UCommerce.Api;
using UCommerce.Runtime;
using UCommerce.Extensions;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassProductController : Umbraco.Web.Mvc.RenderMvcController
    {
		public ActionResult Index()
		{
			ProductViewModel productModel = new ProductViewModel();

			productModel = MapProduct(UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentProduct);

            return View("/views/mc/product.cshtml", productModel);
		}

		private ProductViewModel MapProduct(UCommerce.EntitiesV2.Product currentProduct)
		{
			var productViewModel = new ProductViewModel(); 
			
			productViewModel.Sku = currentProduct.Sku;

			productViewModel.Name = currentProduct.DisplayName();

			productViewModel.LongDescription = currentProduct.LongDescription();

			productViewModel.PriceCalculation = UCommerce.Api.CatalogLibrary.CalculatePrice(currentProduct);

			productViewModel.VariantSku = currentProduct.VariantSku;
			productViewModel.IsVariant = currentProduct.IsVariant;

			foreach (UCommerce.EntitiesV2.Product variantProduct in currentProduct.Variants)
			{
				productViewModel.Variants.Add(MapProduct(variantProduct));
			}

			return productViewModel;
		}

		[HttpPost]
		public ActionResult Index(AddToBasketViewModel model)
		{
			TransactionLibrary.AddToBasket(1, model.Sku, model.VariantSku);
            return Index();
        }
    }
}