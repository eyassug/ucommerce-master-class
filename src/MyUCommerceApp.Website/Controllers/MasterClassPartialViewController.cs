using System.Collections.Generic;
using System.Web.Mvc;
using MyUCommerceApp.Website.Models;
using UCommerce.Api;
using UCommerce.Extensions;

namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassPartialViewController : Umbraco.Web.Mvc.SurfaceController
    {
        public ActionResult CategoryNavigation()
        {
            var categoryNavigation = new CategoryNavigationViewModel();
           
            categoryNavigation.Categories = MapCategories(UCommerce.Api.CatalogLibrary.GetRootCategories());

            return View("/views/mc/PartialViews/CategoryNavigation.cshtml", categoryNavigation);
        }

        private IList<CategoryViewModel> MapCategories(ICollection<UCommerce.EntitiesV2.Category> categoriesToMap)
        {
            var categoriesToReturn = new List<CategoryViewModel>();

            foreach (var category in categoriesToMap)
            {
                var categoryViewModel = new CategoryViewModel();

                categoryViewModel.Name = category.DisplayName();

                categoryViewModel.Categories = MapCategories(UCommerce.Api.CatalogLibrary.GetCategories(category));

                categoryViewModel.Url = "/category?category=" + category.CategoryId;

                categoriesToReturn.Add(categoryViewModel);
            }

            return categoriesToReturn;
        }
    }
}