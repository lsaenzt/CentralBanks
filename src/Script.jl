using Dates, .CentralBanks

CentralBanks.BdE_tiposInteres("//datos02/9763-AnalisisyPlanificacion_Financiera/D. Datos/7. Tipos", Dates.Date(2005))
CentralBanks.ECB_FxRates("//datos02/9763-AnalisisyPlanificacion_Financiera/D. Datos/7. Tipos", Dates.Date(2005))

CentralBanks.BdE_be04("//datos02/9763-AnalisisyPlanificacion_Financiera/D. Datos/3. BdE", Dates.Date(2005))
CentralBanks.BdE_be02("//datos02/9763-AnalisisyPlanificacion_Financiera/D. Datos/3. BdE", Dates.Date(2005))
CentralBanks.BdE_be19("//datos02/9763-AnalisisyPlanificacion_Financiera/D. Datos/3. BdE", Dates.Date(2005))

CentralBanks.combinaciones(ans)