#студент ИИС ПМИ 4-1
#Санисло К. А.

library('data.table') 
library('moments')  
library('lattice')
library('ggplot2') 

fileURL <- 'https://raw.githubusercontent.com/aksyuk/R-data/master/COMTRADE/040510-Imp-RF-comtrade.csv'
#директория для данных
if (!file.exists('./data')) {
  dir.create('./data')
}
#файл с логом загрузок
if (!file.exists('./data/download.log')) {
  file.create('./data/download.log')
}
#запись в лог
if (!file.exists('./data/040510-Imp-RF-comtrade.csv')) {
  download.file(fileURL, './data/040510-Imp-RF-comtrade.csv')
  # сделать запись в лог
  write(paste('Файл "040510-Imp-RF-comtrade.csv" загружен', Sys.time()), 
        file = './data/download.log', append = T)
}
#данные из файла во фрейм
if (!exists('DT')){
  DT <- data.table(read.csv('./data/040510-Imp-RF-comtrade.csv', as.is = T))
}

dim(DT)
str(DT)
DT

DT[, Netweight.kg := as.double(Netweight.kg)]
# считаем медианы и округляем до целого, как исходные данные
DT[, round(median(.SD$Netweight.kg, na.rm = T), 0), 
   by = Year]

# сначала все забиваем медианами
DT[, Netweight.kg.median := 
     round(median(.SD$Netweight.kg, na.rm = T), 0), 
   by = Year]
# копируем не пропущенные значения 
DT[!is.na(Netweight.kg), 
   Netweight.kg.median := Netweight.kg]

# смотрим результат
DT[, Netweight.kg, Netweight.kg.median]
DT[is.na(Netweight.kg), 
   Netweight.kg, Netweight.kg.median]
#задаём флажок для метки значений которые раньше были пустыми
DT[, flag := 0]
DT[is.na(Netweight.kg), flag := 1]
DT[, flag := as.factor(flag)]
#строим график разброса
USD <- DT$Trade.Value.USD
Netweight <- DT$Netweight.kg.median

gp <- ggplot(DT,
             aes(x = USD, y = Netweight))
gp <- gp + geom_point()
gp
gp <- gp + geom_point(aes(color = flag))
gp
gp <- gp + labs(title = "Зависимость массы поставки от её стоимости", 
                x = "Стоимость в USD", y = "Масса поставки (кг)") 
gp
#отрегулируем диапазон значений системы координат для изменения масштаба
gp <- gp + coord_cartesian(xlim = c(0, 25000), ylim = c(0, 50000))
gp

png(filename = "Rplot.png", units = "px", 
    width = 800, height = 600)
gp
dev.off()
