# This is a Datadog dashboard for the Datadog Demo application.
# It tries to showcase some of the features of Datadog demo in one place.

resource "datadog_dashboard_json" "dashboard_json" {
  dashboard = <<EOF
{
    "title": "Datadog Demo Dashboard for ${var.common_tags["Environment"]} Environment",
    "description": "This is a dashboard for the Datadog Demo application. This dashboard is created by Terraform.",
    "widgets": [
        {
            "id": 2568416700443922,
            "definition": {
                "title": "Infrastructure Map",
                "title_size": "16",
                "title_align": "left",
                "type": "hostmap",
                "requests": {
                    "fill": {
                        "q": "avg:system.cpu.user{application:${var.common_tags["Application"]},environment:${var.common_tags["Environment"]}} by {host}"
                    }
                },
                "node_type": "host",
                "no_metric_hosts": true,
                "no_group_hosts": true,
                "group": [],
                "scope": [
                    "application:${var.common_tags["Application"]}",
                    "environment:${var.common_tags["Environment"]}"
                ],
                "style": {
                    "palette": "green_to_orange",
                    "palette_flip": false
                }
            },
            "layout": {
                "x": 0,
                "y": 0,
                "width": 4,
                "height": 4
            }
        },
        {
            "id": 6447294220868308,
            "definition": {
                "title": "API Logs in the last hour",
                "title_size": "16",
                "title_align": "left",
                "time": {
                    "live_span": "1h"
                },
                "requests": [
                    {
                        "response_format": "event_list",
                        "query": {
                            "data_source": "logs_stream",
                            "query_string": "service:${var.aws_prefix}-api",
                            "indexes": [],
                            "storage": "hot"
                        },
                        "columns": [
                            {
                                "field": "status_line",
                                "width": "auto"
                            },
                            {
                                "field": "timestamp",
                                "width": "auto"
                            },
                            {
                                "field": "host",
                                "width": "auto"
                            },
                            {
                                "field": "content",
                                "width": "auto"
                            }
                        ]
                    }
                ],
                "type": "list_stream"
            },
            "layout": {
                "x": 4,
                "y": 0,
                "width": 7,
                "height": 4
            }
        },
        {
            "id": 1453884690032044,
            "definition": {
                "title": "API Log Counts by status in the last hour",
                "title_size": "16",
                "title_align": "left",
                "time": {
                    "live_span": "1h"
                },
                "type": "toplist",
                "requests": [
                    {
                        "queries": [
                            {
                                "data_source": "logs",
                                "name": "query1",
                                "search": {
                                    "query": "service:${var.aws_prefix}-api"
                                },
                                "indexes": [
                                    "*"
                                ],
                                "compute": {
                                    "aggregation": "count"
                                },
                                "group_by": [
                                    {
                                        "facet": "status",
                                        "limit": 10,
                                        "sort": {
                                            "aggregation": "count",
                                            "order": "desc"
                                        }
                                    }
                                ],
                                "storage": "hot"
                            }
                        ],
                        "formulas": [
                            {
                                "formula": "query1",
                                "limit": {
                                    "count": 10,
                                    "order": "desc"
                                }
                            }
                        ],
                        "response_format": "scalar"
                    }
                ]
            },
            "layout": {
                "x": 0,
                "y": 4,
                "width": 4,
                "height": 3
            }
        },
        {
            "id": 7791921791226530,
            "definition": {
                "title": "File upload events in the last hour",
                "title_size": "16",
                "title_align": "left",
                "time": {
                    "live_span": "1h"
                },
                "requests": [
                    {
                        "query": {
                            "data_source": "event_stream",
                            "query_string": "service:ddog-demo-api",
                            "event_size": "l"
                        },
                        "response_format": "event_list",
                        "columns": []
                    }
                ],
                "type": "list_stream"
            },
            "layout": {
                "x": 4,
                "y": 4,
                "width": 7,
                "height": 7
            }
        },
        {
            "id": 6482304619312110,
            "definition": {
                "title": "API captured log patterns in the last hour",
                "title_size": "16",
                "title_align": "left",
                "time": {
                    "live_span": "1h"
                },
                "requests": [
                    {
                        "response_format": "event_list",
                        "columns": [
                            {
                                "field": "status_line",
                                "width": "auto"
                            },
                            {
                                "field": "message",
                                "width": "auto"
                            },
                            {
                                "field": "matches",
                                "width": "auto"
                            },
                            {
                                "field": "volume",
                                "width": "auto"
                            }
                        ],
                        "query": {
                            "data_source": "logs_pattern_stream",
                            "query_string": "service:${var.aws_prefix}-api",
                            "indexes": [],
                            "group_by": [
                                {
                                    "facet": "service"
                                }
                            ]
                        }
                    }
                ],
                "type": "list_stream"
            },
            "layout": {
                "x": 0,
                "y": 7,
                "width": 4,
                "height": 4
            }
        },
        {
            "id": 3506802332678782,
            "definition": {
                "title": "Data Lake Logs - 24 hours",
                "title_size": "16",
                "title_align": "left",
                "time": {
                    "live_span": "1d"
                },
                "requests": [
                    {
                        "response_format": "event_list",
                        "columns": [
                            {
                                "field": "status_line",
                                "width": "auto"
                            },
                            {
                                "field": "timestamp",
                                "width": "auto"
                            },
                            {
                                "field": "content",
                                "width": "compact"
                            }
                        ],
                        "query": {
                            "data_source": "logs_stream",
                            "query_string": "source:s3     ${var.aws_prefix}-data-lake",
                            "indexes": [],
                            "storage": "hot"
                        }
                    }
                ],
                "type": "list_stream"
            },
            "layout": {
                "x": 0,
                "y": 11,
                "width": 11,
                "height": 4
            }
        }
    ],
    "template_variables": [
        {
            "name": "application",
            "prefix": "application",
            "available_values": [],
            "default": "${var.common_tags["Application"]}"
        },
        {
            "name": "environment",
            "prefix": "environment",
            "available_values": [],
            "default": "${var.common_tags["Environment"]}"
        }
    ],
    "layout_type": "ordered",
    "notify_list": [],
    "reflow_type": "fixed"
}
  EOF
}
