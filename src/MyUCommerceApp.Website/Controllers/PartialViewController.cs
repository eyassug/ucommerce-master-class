﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce.MasterClass.Website.Models;

namespace UCommerce.MasterClass.Website.Controllers
{
	public class PartialViewController : System.Web.Mvc.Controller
	{
		public ActionResult CategoryNavigation()
		{
			var categoryNavigation = new CategoryNavigationViewModel();

			return View("/views/PartialViews/CategoryNavigation.cshtml", categoryNavigation);
		}

		private IList<CategoryViewModel> MapCategories(ICollection<UCommerce.EntitiesV2.Category> categoriesToMap)
		{
			var categoriesToReturn = new List<CategoryViewModel>();

			return categoriesToReturn;
		} 
	}
}