using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CookComputing.Blogger;
using MyUCommerceApp.Website.Models;
using UCommerce.Api;
namespace MyUCommerceApp.Website.Controllers
{
	public class MasterClassPartialViewController : Umbraco.Web.Mvc.SurfaceController
    {
        public ActionResult CategoryNavigation()
        {
            var categoryNavigation = new CategoryNavigationViewModel();

            categoryNavigation.Categories = MapCategories(UCommerce.Api.CatalogLibrary.GetRootCategories());

            return View("/views/PartialViews/CategoryNavigation.cshtml", categoryNavigation);
        }

        private IList<CategoryViewModel> MapCategories(ICollection<UCommerce.EntitiesV2.Category> categoriesToMap)
        {
            var categoriesToReturn = new List<CategoryViewModel>();

            foreach (var category in categoriesToMap)
            {
                var categoryViewModel = new CategoryViewModel();

                categoryViewModel.Name = category.Name;

                categoryViewModel.Categories = MapCategories(UCommerce.Api.CatalogLibrary.GetCategories(category));

                categoriesToReturn.Add(categoryViewModel);
            }

            return categoriesToReturn;
        }
    }
}