﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using UCommerce.Content;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.Library.Context
{
	public class MyCatalogContext : CatalogContext
	{
		private readonly IMemberService _memberService;

		public MyCatalogContext(IDomainService domainService, 
			IMemberService memberService) : base(domainService)
		{
			_memberService = memberService;
		}

		public override string CurrentCatalogName
		{
			get
			{
				if (_memberService.IsLoggedIn() 
					|| HttpContext.Current.Request.QueryString["loggedin"] != null)
					return "Private";

				return base.CurrentCatalogName;
			}
			set
			{
				base.CurrentCatalogName = value;
			}
		}
	}
}
