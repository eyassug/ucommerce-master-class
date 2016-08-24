using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using NHibernate.Transform;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
    public class OrderReport
    {
        public string StoreName { get; set; }

        public string CustomerFirstName { get; set; }

        public string OrderStatus { get; set; }

        public string CustomerEmail { get; set; }

        public string OrderNumber { get; set; }

        public decimal OrderTotal { get; set; }
    }
    public class OrderReportQuery : ICannedQuery<OrderReport>
    {
        public OrderReportQuery()
        {
            
        }

        public IEnumerable<OrderReport> Execute(ISession session)
        {
            return session.CreateQuery(@"
                SELECT
                    order.ProductCatalogGroup.Name AS StoreName,
                    order.Customer.FirstName AS CustomerFirstName,
                    order.Customer.EmailAddress AS CustomerEmail,
                    order.OrderStatus.Name AS OrderStatus,
                    order.OrderTotal AS OrderTotal,
                    order.OrderNumber AS OrderNumber
                FROM PurchaseOrder order")
                .SetResultTransformer(new AliasToBeanResultTransformer(typeof(OrderReport)))
                .Future<OrderReport>()
                .ToList();
        }
    }
}
