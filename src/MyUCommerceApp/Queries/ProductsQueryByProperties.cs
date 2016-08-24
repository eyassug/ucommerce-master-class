using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
    public class ProductsQueryByProperties : UCommerce.EntitiesV2.Queries.ICannedQuery<UCommerce.EntitiesV2.Product>
    {
        private readonly string _fieldName;
        private readonly string _fieldValue;

        public ProductsQueryByProperties(string fieldName, string fieldValue)
        {
            _fieldName = fieldName;
            _fieldValue = fieldValue;
        }
        public IEnumerable<Product> Execute(NHibernate.ISession session)
        {
            return session
                .Query<Product>()
                .Where(
                    product => product.ProductProperties.Any(property => property.Value == _fieldValue &&
                                         property.ProductDefinitionField.Name == _fieldName)).ToList();
        }
    }
}
