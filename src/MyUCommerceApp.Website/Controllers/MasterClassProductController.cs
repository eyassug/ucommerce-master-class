using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using UCommerce.Api;
using UCommerce.Runtime;
using UCommerce.Extensions;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassProductController : Umbraco.Web.Mvc.RenderMvcController
    {
		public ActionResult Index()
		{
			ProductViewModel productModel = new ProductViewModel();

		    UCommerce.EntitiesV2.Product currentProduct = UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentProduct;

		    productModel.Sku = currentProduct.Sku;
		    productModel.PriceCalculation = UCommerce.Api.CatalogLibrary.CalculatePrice(currentProduct);
		    productModel.Name = currentProduct.DisplayName();
		    productModel.LongDescription = currentProduct.LongDescription();
		    productModel.Variants = MapVariants(currentProduct.Variants);

            return View("/views/mc/product.cshtml", productModel);
		}

		private IList<ProductViewModel> MapVariants(ICollection<Product> variants)
		{
			var variantModels = new List<ProductViewModel>();

		    foreach (var variant in variants)
		    {
		        ProductViewModel model = new ProductViewModel();
		        model.Sku = variant.Sku;
		        model.VariantSku = variant.VariantSku;
		        model.Name = variant.DisplayName();

                variantModels.Add(model);
		    }

			return variantModels;
		}

		[HttpPost]
		public ActionResult Index(AddToBasketViewModel model)
		{
            
		    UCommerce.Api.TransactionLibrary.AddToBasket(1, model.Sku, model.VariantSku);
            return Index();
        }
    }
}