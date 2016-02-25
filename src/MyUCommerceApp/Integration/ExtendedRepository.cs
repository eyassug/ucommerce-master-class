using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Integration
{
	public class ExtendedRepository<T> : Repository<T> where T : class
	{
		public ExtendedRepository(ISessionProvider sessionProvider) : base(sessionProvider)
		{
		}

		public override IQueryable<T> Select(Expression<Func<T, bool>> expression)
		{
			var baseQuery = base.Select(expression);
			if (typeof (T) == typeof (Product))
			{
				var tempQuery = (baseQuery as IQueryable<Product>).Where(x => x.IsVariant);
				return tempQuery as IQueryable<T>;
			}

			return baseQuery;
		}
	}
}
