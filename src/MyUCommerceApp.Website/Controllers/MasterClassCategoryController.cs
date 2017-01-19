using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;
using UCommerce.Api;
using UCommerce.Extensions;
using MyUCommerceApp.Website.Models;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassCategoryController : Umbraco.Web.Mvc.RenderMvcController
	{
	    public MasterClassCategoryController()
	    {
	        
	    }
        public ActionResult Index()
        {
            var categoryViewModel = new CategoryViewModel();

            UCommerce.EntitiesV2.Category currentCategory =
                UCommerce.Runtime.SiteContext.Current.CatalogContext.CurrentCategory;

            categoryViewModel.Name = currentCategory.DisplayName();
            categoryViewModel.Products = MapProducts(UCommerce.Api.CatalogLibrary.GetProducts(currentCategory));

            return View("/views/mc/category.cshtml", categoryViewModel);
        }

        private IList<ProductViewModel> MapProducts(ICollection<Product> productsInCategory)
        {
            IList<ProductViewModel> productViews = new List<ProductViewModel>();

            foreach (UCommerce.EntitiesV2.Product product in productsInCategory)
            {
                ProductViewModel model = new ProductViewModel();
                model.Sku = product.Sku;
                model.Url = "/product?product=" + product.ProductId;
                model.Name = product.DisplayName();
                model.PriceCalculation = UCommerce.Api.CatalogLibrary.CalculatePrice(product);
                productViews.Add(model);
            }

            return productViews;
        }
    }
}