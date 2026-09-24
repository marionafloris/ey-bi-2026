-- 1. ¿Cuál es la edad promedio de los estudiantes que tienen calificaciones sobresalientes? Complete la tabla con EXCELENTE si tienen un 9 o un 10, BUENO si tienen un 7 u 8, APROBADO si tienen un 5 o un 6, y REPROBADO si tienen menos de 5.
SELECT
       CASE 
       WHEN g.grades >= 9 THEN 'EXCELENTE'
       WHEN g.grades >= 7 THEN 'BUENO'
       WHEN g.grades >= 5 THEN 'APROBADO'
       ELSE 'REPROBADO'
END AS categoria_calificacion,
ROUND(AVG(TIMESTAMPDIFF(YEAR, s.dob, CURDATE())), 2) AS edad_promedio
FROM students s
INNER JOIN grades g ON s.student_id = g.student_id
GROUP BY        
CASE 
       WHEN g.grades >= 9 THEN 'EXCELENTE'
       WHEN g.grades >= 7 THEN 'BUENO'
       WHEN g.grades >= 5 THEN 'APROBADO'
       ELSE 'REPROBADO'
END
ORDER BY field(categoria_calificacion,
'EXCELENTE',
'BUENO',
'APROBADO',
'REPROBADO'
);
-- 2. ¿Cuál es la edad media de los estudiantes por universidad?
SELECT
    u.uni_name AS university_name,
    ROUND(
        AVG(TIMESTAMPDIFF(YEAR, s.dob, CURDATE())),
        0
    ) AS average_age
FROM students AS s
INNER JOIN campus AS c
    ON s.city = c.city
INNER JOIN university AS u
    ON c.university_id = u.university_id
GROUP BY
    u.university_id,
    u.uni_name
ORDER BY average_age DESC;
-- 3. ¿Cuál es la proporción de alumnos que suspendieron cada asignatura? Indique el nombre de la asignatura, el número de alumnos que suspendieron, el número total de alumnos y la proporción de alumnos que suspendieron (en porcentaje) para cada asignatura. Muestre los resultados en orden descendente según la proporción de alumnos que suspendieron.
SELECT
sub.subject_id,
sub.subj_name AS asignatura,
COUNT(DISTINCT CASE
WHEN g.grades < 5 THEN g.student_id
END) AS alumnos_suspendidos,
COUNT(DISTINCT g.student_id) AS total_alumnos,
ROUND(
100.0 * COUNT(DISTINCT CASE
WHEN g.grades < 5 THEN g.student_id
END)
/ NULLIF(COUNT(DISTINCT g.student_id), 0),
2
) AS porcentaje_suspendidos
FROM subjects sub
INNER JOIN grades g
ON sub.subject_id = g.subject_id
GROUP BY
sub.subject_id,
sub.subj_name
ORDER BY
porcentaje_suspendidos DESC,
sub.subj_name;
-- 4. ¿Cuál es la nota media de los estudiantes que han realizado un Erasmus en comparación con los que no lo han hecho?
SELECT
CASE
WHEN ia.student_id IS NOT NULL THEN 'w_erasmus'
ELSE 'wo_erasmus'
END AS estado_erasmus,
ROUND(AVG(g.grades), 2) AS nota_media
FROM students s
INNER JOIN grades g
ON s.student_id = g.student_id
LEFT JOIN (
SELECT DISTINCT student_id
FROM international_agreement
) ia
ON s.student_id = ia.student_id
GROUP BY estado_erasmus;
-- 5. Para cada universidad, identifique el número de títulos de licenciatura, maestría y doctorado otorgados. Proporcione la identificación y el nombre de la universidad junto con el recuento de cada tipo de título.
SELECT
u.university_id,
u.uni_name AS universidad,
COUNT(CASE
WHEN b.bachelor_id LIKE 'B%' THEN 1
END) AS licenciaturas,
COUNT(CASE
WHEN b.bachelor_id LIKE 'M%' THEN 1
END) AS maestrias,
COUNT(CASE
WHEN b.bachelor_id LIKE 'D%' THEN 1
END) AS doctorados
FROM university u
LEFT JOIN bachelor b
ON u.university_id = b.university_id
GROUP BY
u.university_id,
u.uni_name
ORDER BY
u.university_id;
-- 6. ¿Cuáles son las 5 universidades con la clasificación media más alta a lo largo de los años? Indique el ID de la universidad, el nombre de la universidad y la clasificación media.
SELECT
u.university_id,
u.uni_name AS universidad,
ROUND(AVG(r.intl_ranking), 0) AS clasificacion_media
FROM university u
INNER JOIN ranking r
ON u.university_id = r.university_id
GROUP BY
u.university_id,
u.uni_name
ORDER BY clasificacion_media DESC
LIMIT 5;
-- 7. Proporcione el número de identificación, el nombre, los apellidos, el nombre de la universidad de origen y el correo electrónico de los 10 estudiantes que hayan participado más veces en un acuerdo internacional.
SELECT
s.student_id,
s.f_name AS nombre,
s.l_name AS apellidos,
u.uni_name AS universidad_origen,
s.email,
COUNT(ia.agreement_code) AS numero_acuerdos
FROM students s
INNER JOIN international_agreement ia
ON s.student_id = ia.student_id
INNER JOIN university u
ON ia.home_university = u.university_id
GROUP BY
s.student_id,
s.f_name,
s.l_name,
u.university_id,
u.uni_name,
s.email
ORDER BY
numero_acuerdos DESC,
s.student_id
LIMIT 10;
-- 8. Realice una consulta en la que, modificando el número de acuerdo internacional, pueda identificar el identificador y el nombre del estudiante que realizó el intercambio, el nombre de la universidad de origen y el nombre de la ciudad donde tuvo lugar el intercambio.
-- NO HACER
-- 9. Busque y muestre el número de universidades que ofrecen cada asignatura, junto con la nota media de cada asignatura.
SELECT
sub.subj_name AS asignatura,
COALESCE(u.numero_universidades, 0) AS numero_universidades,
ROUND(g.nota_media, 0) AS nota_media
FROM subjects sub
LEFT JOIN (
SELECT
subject_id,
COUNT(DISTINCT university_id) AS numero_universidades
FROM uni_subj
GROUP BY subject_id
) u
ON sub.subject_id = u.subject_id
LEFT JOIN (
SELECT
subject_id,
AVG(grades) AS nota_media
FROM grades
GROUP BY subject_id
) g
ON sub.subject_id = g.subject_id
ORDER BY
sub.subj_name;
-- 10. Encuentre las 5 ciudades con el mayor porcentaje de estudiantes con calificaciones sobresalientes (9 o 10). Indique la ciudad, el estado y el porcentaje de estudiantes sobresalientes de cada ciudad.
SELECT
    s.city AS City,
    s.state AS State,
    ROUND(
        100.0 * SUM(CASE WHEN g.grades >= 9 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS Percentage_Outstanding
FROM students s
INNER JOIN grades g
    ON s.student_id = g.student_id
GROUP BY s.city, s.state
ORDER BY Percentage_Outstanding DESC
LIMIT 5;
-- 11. Compara las universidades que envían más estudiantes con las universidades que reciben más estudiantes. Hazlo en dos consultas.
-- 11.1 Universidades que más estudiantes envían.
SELECT
    u.uni_name,
    COUNT(*) AS sent_students
FROM university u
INNER JOIN international_agreement ia
    ON u.university_id = ia.home_university
GROUP BY u.university_id, u.uni_name
ORDER BY sent_students DESC
LIMIT 5;
-- 11.2 Universidades que más estudiantes reciben
SELECT
u.uni_name,
COUNT(*) AS received_students
FROM university u
INNER JOIN international_agreement ia
ON u.university_id = ia.away_university
GROUP BY u.university_id, u.uni_name
ORDER BY received_students DESC
LIMIT 5;
-- Bonus: Ahora puede intentar unir ambas consultas utilizando el operador «UNION ALL».
(SELECT
    u.uni_name,
    COUNT(*) AS sent_students,
    NULL AS received_students
FROM university u
INNER JOIN international_agreement ia
    ON u.university_id = ia.home_university
GROUP BY u.university_id, u.uni_name
ORDER BY sent_students DESC
LIMIT 5)
UNION ALL
(SELECT
    u.uni_name,
    NULL AS sent_students,
    COUNT(*) AS received_students
FROM university u
INNER JOIN international_agreement ia
    ON u.university_id = ia.away_university
GROUP BY u.university_id, u.uni_name
ORDER BY received_students DESC
LIMIT 5);