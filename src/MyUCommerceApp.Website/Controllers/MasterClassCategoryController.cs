using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using UCommerce.Extensions;
using UCommerce.Runtime;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassCategoryController : Umbraco.Web.Mvc.RenderMvcController
	{
        public ActionResult Index()
        {
            var categoryViewModel = new CategoryViewModel();

            var currentCategory = UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentCategory;

            categoryViewModel.Name = currentCategory.DisplayName();
            categoryViewModel.Description = currentCategory.Description();

            categoryViewModel.Products = MapProducts(UCommerce.Api.CatalogLibrary.GetProducts(currentCategory));

            return View("/views/mc/category.cshtml", categoryViewModel);
        }

        private IList<ProductViewModel> MapProducts(ICollection<Product> productsInCategory)
        {
            IList<ProductViewModel> productViews = new List<ProductViewModel>();

            foreach (var product in productsInCategory)
            {
                var productViewModel = new ProductViewModel();

                productViewModel.Sku = product.Sku;
                productViewModel.Name = product.DisplayName();
                productViewModel.Url = "/product?product=" + product.ProductId;

                productViewModel.PriceCalculation = UCommerce.Api.CatalogLibrary.CalculatePrice(product);

                productViews.Add(productViewModel);
            }

            return productViews;
        }
    }
}